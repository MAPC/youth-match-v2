import Ember from 'ember';
import { action } from 'ember-decorators/object';

export default Ember.Route.extend({

  @action
  didTransition() {
    const user = this.modelFor('dashboard');
    this.transitionTo(`dashboard.${user.get('account_type')}`);
  }

});
