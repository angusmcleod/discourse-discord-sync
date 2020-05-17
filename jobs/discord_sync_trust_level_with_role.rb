module Jobs
  class DiscordSyncTrustLevelWithRole < ::Jobs::Scheduled
    every 24.hours

    def execute(args={})
      return unless SiteSetting.respond_to?(:discord_sync_enabled) &&
                    SiteSetting.discord_sync_enabled &&
                    SiteSetting.discord_sync_role_name.present? &&
                    SiteSetting.discord_sync_trust_level.present?
      
      guild_id = SiteSetting.discord_sync_guild_id
      trust_level = SiteSetting.discord_sync_trust_level
      discord_role = SiteSetting.discord_sync_role_name
      discord = ::DiscordSync::Discord
      
      log("
        Sync started.<br>
        Discourse trust level: #{trust_level}.<br>
        Discord role #{discord_role}
      ")

      guild = discord.request('GET', "/guilds/#{guild_id}")
      role = guild["roles"].select { |role| role['name'] == discord_role }.first
      discord_users = discord.request('GET', "/guilds/#{guild_id}/members", query: { limit: 1000 })

      role_users = discord_users.select { |u| u['roles'].find { |role_id| role_id == role['id'] } && !u['user']['bot'] }
      non_role_users = discord_users - role_users

      role_users = role_users.map { |u| u['user'] }
      non_role_users = non_role_users.map { |u| u['user'] }

      verified_usernames = User.where("users.trust_level >= ?", trust_level)
        .joins("LEFT JOIN user_custom_fields ucf ON users.id = ucf.user_id")
        .where("ucf.name = 'discord_username' AND ucf.value IS NOT NULL")
        .pluck("ucf.value")
      
      add_users = non_role_users.select { |u| verified_usernames.include?(u['username']) }
      remove_users = role_users.select { |u| !verified_usernames.include?(u['username']) }

      add_users.each do |user|
        discord.request('PUT', "/guilds/#{guild_id}/members/#{user['id']}/roles/#{role['id']}")
      end
      
      if add_users.any?
        log("Users given #{discord_role} role", users: add_users.map { |u| u['username'] })
      end

      remove_users.each do |user|
        discord.request('DELETE', "/guilds/#{guild_id}/members/#{user['id']}/roles/#{role['id']}")
      end
      
      if remove_users.any?
        log("Users removed from #{discord_role} role", users: remove_users.map { |u| u['username'] })
      end
      
      log("
        Sync complete.<br>
        Discord users with #{discord_role} role: #{role_users.count}.<br>
        Discourse users with trust level #{trust_level} and Discord username: #{verified_usernames.count}
      ")
    end
    
    def log(message, opts={})
      ::DiscordSync::Log.create(message, opts)
    end
  end
end
