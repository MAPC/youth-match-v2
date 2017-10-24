import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  /**
   * Members
   */

  queryParams: ['min', 'max'],

  searchQuery: '',
  min: 0,
  max: 20,

  @computed('min', 'max') 
  pageSize(min, max) {
    return Math.abs(max - min);
  },


  @computed('model.picks.[]')
  numberChosen(picks) {
    return picks.get('length');
  },

  @computed('model.positions')
  totalAllotments(positions) {
    return positions.get('firstObject.open_positions');
  },


  @computed('totalAllotments', 'model.user.allocation_rule')
  directSelectAllotments(totalAllotments, allocationRule) {
    return Math.floor(totalAllotments / allocationRule);
  },


  @computed('numberChosen', 'directSelectAllotments')
  hasHitLimit(numberChosen, directSelectAllotments) {
    return numberChosen >= directSelectAllotments;
  },


  @computed('model.requisitions.[]')
  interestedApplicants(requisitions)  {
    return requisitions.filter(requisition => requisition.get('applicant_status') === 'interested')
                       .map(requisition => requisition.get('applicant'));
  },


  @computed('model.applicants.[]', 'interestedApplicants')
  disinterestedApplicants(applicants, interestedApplicants) {
    return applicants.filter(applicant => interestedApplicants.indexOf(applicant) === -1)
                     .sortBy('last_name', 'first_name');
  },


  @computed('interestedApplicants', 'disinterestedApplicants', 'searchQuery')
  filteredApplicants(interested, disinterested, query) {
    const { min, max } = this.getProperties('min', 'max');
    let applicants  = interested.concat(disinterested);
    query = query.toLowerCase();

    if (query.length >= 2) {
      applicants = applicants.filter(x => { 
        var firstName = (x.get('first_name') || '').toLowerCase(),
            lastName = (x.get('last_name') || '').toLowerCase();

        return firstName.startsWith(query) || lastName.startsWith(query); 
      });
    }

    return applicants.slice(min, max);
  },



  /**
   * Methods
   */
  

  @action
  pickApplicant(applicant) {
     
  }

});
