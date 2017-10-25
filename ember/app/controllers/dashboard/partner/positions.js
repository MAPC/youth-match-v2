import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  parent: Ember.inject.controller('dashboard.partner'),


  @action
  removePick(pick) {
  
  },


  @action
  changePosition(pick, event) {

  },


  @action
  submitForm() {
    const picks = this.get('model.picks');

    console.log(picks);
  }

});
