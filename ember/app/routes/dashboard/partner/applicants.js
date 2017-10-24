import Ember from 'ember';
import RSVP from 'rsvp';
import { flatten } from '../../../helpers/flatten';


export default Ember.Route.extend({

  model() {
    const positions = this.modelFor('dashboard.partner');
    const user = this.modelFor('dashboard');

    return RSVP.hash({
      user,
      positions,
      applicants: this.store.findAll('applicant'),
      picks: this.store.findAll('pick'),
      requisitions: RSVP.all(positions.mapBy('requisitions'))
                        .then(collection => flatten(collection)),
    });
  },

});
