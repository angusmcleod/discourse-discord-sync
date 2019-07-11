class Discord::Sync
  def self.start(args={})
    Jobs.enqueue(:discord_sync_trust_level_with_role, args)
  end
end
