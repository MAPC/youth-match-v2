import Ember from 'ember';
import RSVP from 'rsvp';
import { flatten } from '../../helpers/flatten';

export default Ember.Route.extend({
 
  model() {
    const user = this.modelFor('dashboard');

    return user.get('positions').then(positions => {
      return RSVP.all(positions.mapBy('requisitions')).then(collection => {
        return flatten(collection);
      });
    });
  }

});
