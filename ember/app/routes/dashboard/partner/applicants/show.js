import Ember from 'ember';
import RSVP from 'rsvp';


export default Ember.Route.extend({

  model(params) {
    const { requisitions } = this.modelFor('dashboard.partner.applicants');

    return RSVP.hash({
      requisitions,
      applicant: this.store.findRecord('applicant', params.applicant_id),
    });
  }

});
