module Jobs
  class DiscordSyncTrustLevelWithRole < Jobs::Scheduled
    every 24.hours

    def execute(args={})
      return unless SiteSetting.discord_sync_role_name.present? &&
                    SiteSetting.discord_sync_trust_level.present?

      guild = Discord.request('GET', "/guilds/#{SiteSetting.discord_guild_id}")
      role = guild["roles"].select { |role| role['name'] == SiteSetting.discord_sync_role_name }.first
      discord_users = Discord.request('GET', "/guilds/#{SiteSetting.discord_guild_id}/members", query: { limit: 1000 })

      role_users = discord_users.select { |u| u['roles'].find { |role_id| role_id == role['id'] } && !u['user']['bot'] }
      non_role_users = discord_users - role_users

      role_users = role_users.map { |u| u['user'] }
      non_role_users = non_role_users.map { |u| u['user'] }

      verified_usernames = User.where("users.trust_level >= ?", SiteSetting.discord_sync_trust_level)
        .joins("LEFT JOIN user_custom_fields ucf ON users.id = ucf.user_id")
        .where("ucf.name = 'discord_username' AND ucf.value IS NOT NULL")
        .pluck("ucf.value")

      add_users = non_role_users.select { |u| verified_usernames.include?(u['username']) }
      remove_users = role_users.select { |u| !verified_usernames.include?(u['username']) }

      log_args = {
        role: SiteSetting.discord_sync_role_name,
        trust_level: SiteSetting.discord_sync_trust_level
      }

      add_users.each do |user|
        Discord.request('PUT', "/guilds/#{SiteSetting.discord_guild_id}/members/#{user['id']}/roles/#{role['id']}")
      end

      log_args[:add_users] = add_users.map { |u| u['username'] } if add_users.any?

      remove_users.each do |user|
        Discord.request('DELETE', "/guilds/#{SiteSetting.discord_guild_id}/members/#{user['id']}/roles/#{role['id']}")
      end

      log_args[:remove_users] = remove_users.map { |u| u['username'] } if remove_users.any?

      Discord::Job.log_completion('sync_trust_level_with_role', log_args)
    end
  end
end
