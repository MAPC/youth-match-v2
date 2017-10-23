import Ember from 'ember';
import RSVP from 'rsvp';
import { flatten } from '../../../helpers/flatten';


export default Ember.Route.extend({

  model() {
    const positions = this.modelFor('dashboard.partner');

    return RSVP.hash({
      applicants: this.store.findAll('applicant'),
      requisitions: RSVP.all(positions.mapBy('requisitions'))
                        .then(collection => flatten(collection)),
    });
  },

});
