import Ember from 'ember';
import RSVP from 'rsvp';


export default Ember.Route.extend({

  model() {
    const youthModel = this.modelFor('dashboard.youth');
    const applicant = youthModel.get('applicant');

    return RSVP.hash({
      positions: this.store.findAll('position'),
      applicant, 
    });
  }

});
