import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import Controller from "@ember/controller";
import { not } from "@ember/object/computed"

export default Controller.extend({
  notAuthorized: not('model.authorized'),

  actions: {
    authorize() {
      const discordUrl = "https://discordapp.com/api/oauth2/authorize";
      const clientId = Discourse.SiteSettings.discord_sync_client_id;
      window.location.href = discordUrl + `?client_id=${clientId}&scope=bot&permissions=8`;
    },

    startSync() {
      this.set('startingSync', true);

      ajax('/discord-sync/start', { type: 'POST' })
        .catch(popupAjaxError)
        .then(result => {
          if (result && result.success) {
            this.set('syncStarted', true);
          }
        }).finally(() => {
          this.set('startingSync', false);
        });
    },
    
    refreshLogs() {
      this.send('refresh');
    },
    
    clearLogs() {
      this.set('loading', true);
      ajax('/discord-sync/logs', { type: 'DELETE' })
        .catch(popupAjaxError)
        .then(result => {
          if (result && result.success) {
            this.send('refresh');
          }
        }).finally(() => {
          this.set('loading', false);
        });
    }
  }
});
