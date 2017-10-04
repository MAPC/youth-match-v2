import Ember from 'ember';
import RSVP from 'rsvp';
import CenterMapOnGeometry from '../../mixins/center-map-on-geometry';
import RouterScroll from 'ember-router-scroll';
import trackPage from '../../mixins/track-page';


export default Ember.Route.extend(trackPage, RouterScroll, CenterMapOnGeometry.reopen({ hashProperty: 'job' }), {

  mapState: Ember.inject.service(),


  model(param) {
    const position = this.modelFor('dashboard.youth').positions.findBy('id', param.id);
    const user = this.modelFor('dashboard.youth').user;

    return RSVP.hash({
      position,
      user
    });
  },

});
