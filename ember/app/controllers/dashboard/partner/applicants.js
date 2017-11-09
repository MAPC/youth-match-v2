import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';
import PaginatedController from '../../PaginatedController';


export default PaginatedController.extend({

  parent: Ember.inject.controller('dashboard.partner'),

  /**
   * Members
   */

  searchQuery: '',
  defaultMax: 20,


  @computed('model.picks.[]')
  pickedApplicants(picks) {
    return picks.mapBy('applicant');
  },


  @computed('model.requisitions.[]') 
  interestedApplicants(requisitions)  {
    return requisitions.map(req => {
                          let applicant = req.get('applicant');
                          applicant.set('currentRequisition', req);

                          return applicant;
                        })
                        .sortBy('last_name', 'first_name');
                       
  },


  @computed('model.applicants.[]', 'interestedApplicants')
  disinterestedApplicants(applicants, interestedApplicants) {
    const applicantIds = interestedApplicants.map(applicant => applicant.get('id'));
    return applicants.filter(applicant => applicantIds.indexOf(applicant.get('id')) === -1)
                     .sortBy('last_name', 'first_name');
  },


  @computed('disinterestedApplicants', 'interestedApplicants')
  modelLength(disinterested, interested) {
    return disinterested.length + interested.length;
  },


  @computed('pickedApplicants.[]', 'interestedApplicants', 'disinterestedApplicants', 'searchQuery', 'min', 'max')
  filteredApplicants(picked, interested, disinterested, query, min, max) {
    const pickedIds = picked.map(applicant => applicant.get('id'));

    let applicants  = interested.concat(disinterested)
                                .filter(applicant => pickedIds.indexOf(applicant.get('id')) === -1);

    if (query.length >= 2) {
      this.resetPage();
      query = query.toLowerCase();

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
      }

      this.store.createRecord('pick', { applicant, position }).save();
    }
  }


});
