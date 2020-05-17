class DiscordSync::Log
  def self.create(message, opts={})
    PluginStore.set('discord_sync', 'logs', list.push({
      message: message,
      date: DateTime.now
    }.merge(opts)))
  end

  def self.list
    [*PluginStore.get('discord_sync', 'logs')].sort_by { |l| l["date"] }.reverse
  end
  
  def self.clear
    PluginStore.set('discord_sync', 'logs', nil)
  end
end
