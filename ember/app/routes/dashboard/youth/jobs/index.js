import Ember from 'ember';
import RouterScroll from 'ember-router-scroll';


export default Ember.Route.extend(RouterScroll, {
  setupController(controller, model) {
    this._super(controller, model);

    const userInterestCategories = model.user.get('applicant_interests');
    const jobsController = this.controllerFor('dashboard.youth.jobs.index');

    jobsController.set('selectedInterestCategories', userInterestCategories);
  }
});
