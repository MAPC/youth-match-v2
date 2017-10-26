import Ember from 'ember';
import RSVP from 'rsvp';


export default Ember.Route.extend({
 
  model() {
    const user = this.modelFor('dashboard');

    return RSVP.hash({
      user, 
      positions: user.get('positions'),
      picks: this.store.findAll('pick'),
    });
  }

});
