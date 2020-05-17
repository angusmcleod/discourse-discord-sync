# name: Discourse Discord Sync
# about: Sync properties between Discourse and Discord
# version: 0.2
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-discord-sync

enabled_site_setting :discord_sync_enabled

add_admin_route 'discord_sync.title', 'discord-sync'
register_asset 'stylesheets/common/discord-sync.scss'
load File.expand_path('../lib/validators/allow_discord_sync_enabled_validator.rb', __FILE__)

after_initialize do
  %w[
    ../lib/discord_sync/engine.rb
    ../lib/discord_sync/discord.rb
    ../lib/discord_sync/log.rb
    ../config/routes.rb
    ../controllers/discord_sync/admin.rb
    ../jobs/discord_sync_trust_level_with_role.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end
  
  register_editable_user_custom_field :discord_username
  whitelist_public_user_custom_field :discord_username
end
