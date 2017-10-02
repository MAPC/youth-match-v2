import Ember from 'ember';
import RSVP from 'rsvp';
import UpdateMapBounds from '../../mixins/update-map-bounds';

const UpdateMapBoundsMixin = UpdateMapBounds.reopen({hashProperty: 'jobs', modelName: 'dashboard'});


export default Ember.Route.extend(UpdateMapBoundsMixin, {

  model() {
    const user = this.modelFor('dashboard');

    return RSVP.hash({
      positions: this.store.findAll('position'),
      user,
    });
  },

});
