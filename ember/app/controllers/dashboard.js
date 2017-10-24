import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  session: Ember.inject.service('session'),

  @computed('model')
  user(model) {
    return model;
  },

  @action
  invalidateSession()  {
    this.get('session').invalidate();
  }

});
