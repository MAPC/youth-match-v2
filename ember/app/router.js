import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('login');
  this.route('dashboard', function() {
    this.route('youth', function() {
      this.route('jobs', function() {
        this.route('job', { path: '/:position_id' });
      });
      this.route('about');
    });
    this.route('partner', function() {
      this.route('applicant', { path: '/applicant/:id' });
      this.route('show-applicant', { path: '/profile/:applicant_id' }, function() {
        this.route('new-pick', { path: 'new' });
      });

      this.route('positions', function() {});
      this.route('applicants');
    });
    this.route('staff', function() {
      this.route('users');
      this.route('applicants');
      this.route('positions');
    });
  });

  this.route('sign-up');
  this.route('signup');
});

export default Router;
