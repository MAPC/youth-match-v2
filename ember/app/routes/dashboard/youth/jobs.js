import Ember from 'ember';
import RSVP from 'rsvp';


export default Ember.Route.extend({

  model() {
    const user = this.modelFor('dashboard.youth');

    return RSVP.hash({
      positions: this.store.findAll('position'),
      user,
    });
  }

});
