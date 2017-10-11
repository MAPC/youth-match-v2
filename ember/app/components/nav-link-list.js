import Ember from 'ember';
import { computed } from 'ember-decorators/object';

export default Ember.Component.extend({

  @computed('accountType')
  isYouth(accountType) {
    return accountType.toLowerCase() === 'youth';
  },


  @computed('accountType')
  isStaff(accountType) {
    return accountType.toLowerCase() === 'staff';
  },


  @computed('accountType')
  isPartner(accountType) {
    return accountType.toLowerCase() === 'partner';
  },


});
