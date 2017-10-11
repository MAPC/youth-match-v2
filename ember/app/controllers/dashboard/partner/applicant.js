import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  fields: [
    'email',
    'mobile_phone',
    'guardian_name',
    'guardian_phone',
    'guardian_email',
    'school_type',
    'bps_school_name',
    'current_grade_level',
    'other_languages',
    'address',
    'home_phone'
  ],

  @computed('model.applicant.interests')
  uniqInterests(interests) {
    return interests.uniq().sort();
  },

  @action
  changeStatus(status) {
    let model = this.get('model');
    model.setProperties({status});
    model.save();
  }

});
