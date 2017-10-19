import Ember from 'ember';
import RSVP from 'rsvp';
import CenterMapOnGeometry from '../../../../mixins/center-map-on-geometry';

const CenterMapMixin = CenterMapOnGeometry.reopen({ hashProperty: 'position' });


export default Ember.Route.extend(CenterMapMixin, {

  mapState: Ember.inject.service(),

  model(param) {
    const youthJobsModel = this.modelFor('dashboard.youth.jobs');
    const positions = youthJobsModel.positions;
    const position = positions.findBy('id', param.position_id);
    const user = youthJobsModel.user;

    return RSVP.hash({ positions, position, user });
  }

});
