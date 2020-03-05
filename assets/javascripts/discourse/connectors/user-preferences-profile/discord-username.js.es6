export default {
  shouldRender(attrs, ctx) {
    return attrs.model.trust_level >= ctx.siteSettings.discord_sync_trust_level;
  }
};
