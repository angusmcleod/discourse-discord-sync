class AllowDiscordSyncEnabledValidator
  def initialize(opts = {})
    @opts = opts
  end

  def valid_value?(val)
    return true if val == "f"
    SiteSetting.discord_sync_bot_token.present? &&
    SiteSetting.discord_sync_client_id.present?
  end

  def error_message
    I18n.t("site_settings.errors.discord_credentials_required");
  end
end
