import Ember from 'ember';
import RSVP from 'rsvp';
import updateMapBounds from '../../../../mixins/update-map-bounds';

const MapBoundsMixin = updateMapBounds.reopen({ hashProperty: 'positions', modelName: 'dashboard.youth.jobs' });


export default Ember.Route.extend(MapBoundsMixin, {

  model() {
    const youthJobsModel = this.modelFor('dashboard.youth.jobs');

    return RSVP.hash({
      positions: youthJobsModel.positions,
      user: youthJobsModel.user,
    });
  },

  setupController(controller, model) {
    this._super(controller, model);

    const userInterestCategories = model.user.get('applicant_interests');
    const jobsController = this.controllerFor('dashboard.youth.jobs');

    jobsController.set('selectedInterestCategories', userInterestCategories);
  }
});
