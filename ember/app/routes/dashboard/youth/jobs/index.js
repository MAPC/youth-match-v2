import Ember from 'ember';
import RSVP from 'rsvp';
import RouterScroll from 'ember-router-scroll';


export default Ember.Route.extend(RouterScroll, {

  model() {
    const user = this.modelFor('dashboard.youth');

    return RSVP.hash({
      positions: this.store.findAll('position'),
      user,
    });
  },

  setupController(controller, model) {
    this._super(controller, model);

    const userInterestCategories = model.user.get('applicant_interests');
    const jobsController = this.controllerFor('dashboard.youth.jobs');

    jobsController.set('selectedInterestCategories', userInterestCategories);
  }
});
