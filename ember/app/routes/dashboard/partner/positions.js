import Ember from 'ember';
import RSVP from 'rsvp';
import { flatten } from '../../../helpers/flatten';

export default Ember.Route.extend({

  model() {
    let user = this.modelFor('dashboard');

    return RSVP.hash({
      user,
      positions: user.get('positions'),
      requisitions: user.get('positions').then(positions => {
        return RSVP.all(positions.mapBy('requisitions')).then(collection => {
          return flatten(collection);
        });
      }),
    });
  },

  afterModel(model) {
    console.log(model.requisitions);
  }

});
