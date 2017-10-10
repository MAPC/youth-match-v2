import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({
  fields: ['site_name', 'latitude', 'longitude'],

  @computed('model.user', 'model.position', 'model.position.applicants.@each.id')
  isInterested: {
    get(user, position) {
      let applicant = user.get('applicant');
      return position.get('applicants').isAny('id', applicant.get('id'));
    },

    set(value, user, position) {
      user.get('applicant').then((applicant) => {
        if (value) {
          position.get('applicants').pushObject(applicant);
          position.save();
        } 
        else {
          position.get('applicants').removeObject(applicant);
          position.save();
        }
      });
    }
  },


  @action 
  toggleInterest() {
    this.toggleProperty('isInterested');
  }

});
