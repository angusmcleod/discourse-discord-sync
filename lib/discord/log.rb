class ::Discord::Log
  def self.set(name, opts={})
    logs = self.list.push({ name: name, completed_at: DateTime.now }.merge(opts))
    PluginStore.set('discord', 'logs', logs)
  end

  def self.list
    [*PluginStore.get('discord', 'logs')]
  end
  
  def self.clear
    PluginStore.set('discord', 'logs', nil)
  end
end
