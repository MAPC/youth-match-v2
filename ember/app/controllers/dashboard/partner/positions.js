import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  parent: Ember.inject.controller('dashboard.partner'),


  @action
  removePick(pick) {
    pick.destroyRecord();
  },


  @action
  changePosition(pick, event) {
    console.log(event.target.value);
    return;

    pick.setProperties({ position });
    pick.save();
  },


  @action
  submitForm() {
    const picks = this.get('model.picks');

    console.log(picks);
  }

});
