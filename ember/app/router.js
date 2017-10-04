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
      this.route('job');
    });
    this.route('partner');
    this.route('staff');
  });
});

export default Router;
