import Ember from 'ember';
import RSVP from 'rsvp';
//import UpdateMapBounds from '../../../mixins/update-map-bounds';

//const UpdateMapBoundsMixin = UpdateMapBounds.reopen({hashProperty: 'jobs', modelName: 'dashboard'});


export default Ember.Route.extend({

  model() {
    const user = this.modelFor('dashboard.youth');

    return RSVP.hash({
      positions: this.store.findAll('position'),
      user,
    });
  }

});
