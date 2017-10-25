import Ember from 'ember';
import { action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  parent: Ember.inject.controller('dashboard.partner.applicants'),
  

  @action
  pickApplicant() {
    const model = this.get('model');

    
  }

});
