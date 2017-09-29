import Ember from 'ember';
import { action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  session: Ember.inject.service('session'),


  @action
  invalidateSession()  {
    this.get('session').invalidate();
  }

});
