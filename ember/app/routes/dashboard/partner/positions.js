import Ember from 'ember';
import RSVP from 'rsvp';
import { flatten } from '../../../helpers/flatten';


export default Ember.Route.extend({

  model() {
    const user = this.modelFor('dashboard');
    const positions = this.modelFor('dashboard.partner');

    return RSVP.hash({
      user,
      positions,
      picks: RSVP.all(positions.mapBy('picks'))
                 .then(collection => flatten(collection)),
    });
  },

});
