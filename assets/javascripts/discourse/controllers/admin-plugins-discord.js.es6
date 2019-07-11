import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Controller.extend({
  notAuthorized: Ember.computed.not('model.authorized'),

  @computed('trustLevel', 'job')
  syncEnabled(trustLevel, job) {
    return trustLevel && job;
  },

  actions: {
    authorize() {
      const discordUrl = "https://discordapp.com/api/oauth2/authorize";
      const clientId = Discourse.SiteSettings.discord_client_id;
      window.location.href = discordUrl + `?client_id=${clientId}&scope=bot&permissions=8`;
    },

    startJob() {
      this.set('startingJob', true);

      ajax('/discord/job/start', { type: 'PUT' })
        .catch(popupAjaxError)
        .then(result => {
          if (result && result.success) {
            this.set('jobStarted', true);
          }
        }).finally(() => this.set('startingJob', false));
    }
  }
});
