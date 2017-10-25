import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  parent: Ember.inject.controller('dashboard.partner'),

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


  @computed('model.requisitions.[]')
  interestedApplicants(requisitions)  {
    return requisitions.map(requisition => {
                          let applicant = requisition.get('applicant');
                          applicant.set('currentRequisition', requisition);

                          return applicant;
                        })
                        .sortBy('last_name', 'first_name');
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
    if (!this.get('parent.hasHitLimit')) {
      let position = null;

      if (applicant.get('currentRequisition')) {
        position = applicant.get('currentRequisition.position').content;
      }
      else {
        const positions = this.get('model.positions').filter(position => position.get('open_positions') > 0);
        position = positions[Math.floor(Math.random() * positions.length)];

        const requisitions = this.get('requisitions');
        requisitions.forEach(requisition => {
          if (requisition.get('applicant') === applicant) {
            position = requisition.get('position');
          }
        });
      }

      console.log(position);
      return;


      this.store.createRecord('pick', { applicant, position }).save();
    }
  }

});
