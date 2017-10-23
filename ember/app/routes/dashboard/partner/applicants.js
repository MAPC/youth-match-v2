import Ember from 'ember';
import RSVP from 'rsvp';


export default Ember.Route.extend({

  model() {
    const requisitions = this.modelFor('dashboard.partner');

    return RSVP.hash({
      applicants: this.store.findAll('applicant'),
      requisitions: requisitions,
    });
  },

  afterModel(model) {
    console.log(model) ;
  }

});
