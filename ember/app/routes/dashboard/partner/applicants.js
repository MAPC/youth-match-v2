import Ember from 'ember';
import RSVP from 'rsvp';
import { flatten } from '../../../helpers/flatten';


export default Ember.Route.extend({

  model() {
    const { user, positions, picks } = this.modelFor('dashboard.partner');

    return RSVP.hash({
      user,
      positions,
      picks, 
      applicants: this.store.query('applicant', { without_offers: true }),
      requisitions: RSVP.all(positions.mapBy('requisitions'))
                        .then(collection => flatten(collection)),
    });
  },

});
