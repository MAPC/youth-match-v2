import Ember from 'ember';
import RSVP from 'rsvp';


export default Ember.Route.extend({

  model() {
    return RSVP.hash({
      applicants: this.store.findAll('applicant'),
      offers: this.store.findAll('offer'),
    });
  },

  afterModel(model) {
    console.log(model);
  }

});
