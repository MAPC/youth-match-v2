import Ember from 'ember';
import RSVP from 'rsvp';
import { on } from 'ember-decorators/object/evented';


export default Ember.Route.extend({

  lotteryStatus: Ember.inject.service(),


  model() {
    const lotteryStatus = this.get('lotteryStatus');

    return RSVP.hash({
      applicants: this.store.query('applicant', { chosen: true }),

      expire: lotteryStatus.getExpire(),
      lottery: lotteryStatus.getLottery(),
      worker: lotteryStatus.getWorker(),
    });
  },

  @on('deactivate')
  stopLotteryStatusUpdates() {
    const lotteryController = this.controllerFor('dashboard.staff.lottery');

    if (lotteryController.get('updateTimer')) {
      clearTimeout(lotteryController.get('updateTimer'));
    }
  },

});
