import Ember from 'ember';
import RSVP from 'rsvp';
import { action } from 'ember-decorators/object';

export default Ember.Route.extend({

  model() {
    let applicant = this.modelFor('applicants.show-applicant');

    return RSVP.hash({
      pick: this.store.createRecord('pick', { applicant }),
      applicant,
      positions: this.modelFor('applicants').user.get('positions')
    });
  },

  @action
  associatePosition(model, position) {
    model.pick.setProperties({ position });
    model.pick.save().then(() => {
      this.transitionTo('dashboard.partner.show-applicant', model.applicant.get('id'));
    });
  }

});
