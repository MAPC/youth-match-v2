import Ember from 'ember';
import { computed } from 'ember-decorators/object';

export default Ember.Component.extend({

  @computed('user')
  isYouth(user) {
    return user.get('account_type').toLowerCase() === 'youth';
  },


  @computed('user')
  isStaff(user) {
    return user.get('account_type').toLowerCase() === 'staff';
  },


  @computed('user')
  isPartner(user) {
    return user.get('account_type').toLowerCase() === 'partner';
  },


});
