import Ember from 'ember';
import RSVP from 'rsvp';
//import CenterMapOnGeometry from '../../../../mixins/center-map-on-geometry';
//import trackPage from '../../../../mixins/track-page';

export default Ember.Route.extend(/*trackPage, CenterMapOnGeometry.reopen({ hashProperty: 'job' }), */ {

  mapState: Ember.inject.service(),

  model(param) {
    const youthJobsModel = this.modelFor('dashboard.youth.jobs');
    const positions = youthJobsModel.positions;
    const position = positions.findBy('id', param.position_id);
    const user = youthJobsModel.user;

    return RSVP.hash({ positions, position, user });
  }

});
