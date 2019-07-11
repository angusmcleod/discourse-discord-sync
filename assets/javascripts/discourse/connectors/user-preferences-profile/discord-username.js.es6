export default {
  setupComponent(attrs, component) {
    component.set('showDiscordUsername', attrs.model.trust_level >= 3);
  }
};
