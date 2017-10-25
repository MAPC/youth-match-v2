import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  @computed('model.requisitions.[]', 'model.applicant')
  requisition(requisitions, applicant) {
    return requisitions.filter(requisition => requisition.get('applicant.id') === applicant.id)[0];
  }
 
});
