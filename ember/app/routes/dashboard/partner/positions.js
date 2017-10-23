import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({

  model() {
    let user = this.modelFor('dashboard');
    let requisitions = this.modelFor('dashboard.partner');

    return RSVP.hash({
      user,
      requisitions,
      positions: user.get('positions'),
    });
  }

});
