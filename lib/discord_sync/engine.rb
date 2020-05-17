module ::DiscordSync
  class Engine < ::Rails::Engine
    engine_name "discord_sync"
    isolate_namespace DiscordSync
  end
end