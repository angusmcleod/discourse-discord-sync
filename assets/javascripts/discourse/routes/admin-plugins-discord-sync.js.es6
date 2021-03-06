import { ajax } from 'discourse/lib/ajax';
import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  model() {
    return ajax('/discord-sync/logs');
  },

  setupController(controller, model) {
    controller.set('model', model);
  },
  
  actions: {
    refresh() {
      this.refresh();
    }
  }
});
