import Ember from 'ember';

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

  actions: {
    changeStatus() {
      
    }
  },

  ac: Ember.inject.controller('dashboard.partner')

});

