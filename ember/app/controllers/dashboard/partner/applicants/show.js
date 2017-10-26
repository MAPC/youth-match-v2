import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  parent: Ember.inject.controller('dashboard.partner.applicants'),

  @computed('model.requisitions', 'model.applicant')
  requisition(requisitions, applicant) {
    return requisitions.filter(req => req.get('applicant.id') === applicant.id)[0];
  },

  @computed('model.applicant', 'model.picks.[]')
  pick(applicant, picks) {
    return picks.filter(pick => pick.get('applicant.id') === applicant.id)[0];
  },

  @computed('pick')
  picked(pick) {
    return !!pick;
  },


  @action
  pickApplicant(applicant) {
    const { parent, requisition } = this.getProperties('parent', 'requisition');

    if (requisition) {
      applicant.set('currentRequisition', requisition);
    }

    parent.pickApplicant(applicant);
  },


  @action
  unpickApplicant() {
    this.get('pick').destroyRecord();
  }
 
});
