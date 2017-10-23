import Ember from 'ember';
import { computed } from 'ember-decorators/object';


export default Ember.Controller.extend({

  @computed('model.requisitions.[]')
  interestedApplicants(requisitions)  {
    return requisitions.map(requisition => requisition.get('applicant'));
  },

  @computed('model.applicants.[]', 'interestedApplicants')
  disinterestedApplicants(applicants, interestedApplicants) {
    return applicants.filter(applicant => interestedApplicants.indexOf(applicant) === -1);
  }

});
