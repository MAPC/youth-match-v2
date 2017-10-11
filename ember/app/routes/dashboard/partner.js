import Ember from 'ember';
import RSVP from 'rsvp';
import { flatten } from '../../helpers/flatten';
import trackPage from '../../mixins/track-page';
import updateMapBounds from '../../mixins/update-map-bounds';


export default Ember.Route.extend(trackPage, {

  model() {
    let user = this.modelFor('dashboard');

    return RSVP.hash({
      user,
      picks: this.store.findAll('pick'),
      requisitions: user.get('positions').then(positions=> {
        return RSVP.all(positions.mapBy('requisitions')).then(collection=> {
          return flatten(collection);
        });
      }),
      applicants: user.get('positions').then(positions=> {
        return this.store.findAll('applicant');
      })
    })
  },

});
