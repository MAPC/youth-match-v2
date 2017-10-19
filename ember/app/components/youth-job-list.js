import Ember from 'ember';
import { action } from 'ember-decorators/object';


export default Ember.Component.extend({

  classNames: ['component', 'youth-job-list'],


  @action
  remove(id) {
    this.get('removeItem')(id);
  }

});
