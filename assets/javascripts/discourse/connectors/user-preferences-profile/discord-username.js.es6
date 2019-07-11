export default {
  setupComponent(attrs, component) {
    component.set('showDiscordUsername', attrs.model.trust_level >= Discourse.SiteSettings.discord_sync_trust_level);
  }
};
