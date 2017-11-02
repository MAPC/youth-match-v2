import Ember from 'ember';
import url from 'npm:url';
import config from '../../../config/environment';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  parent: Ember.inject.controller('dashboard.partner'),

  session: Ember.inject.service(),
  ajax: Ember.inject.service(),

  submitted: false,

  errorMessage: '',


  @computed('parent.directSelectAllotments', 'model.picks.length')
  directAllotmentsLeft(allotments, picksLength) {
    return allotments - picksLength;
  },


  @computed('model.picks.[]')
  queuedPicks(picks) {
    return picks.filter(pick => !pick.get('status')).length > 0; 
  },


  @action
  removePick(pick) {
    pick.destroyRecord();
  },


  @action
  changePosition(pick, event) {
    const title = event.target.value;
    const positions = this.get('model.positions');

    const position = positions.filter(pos => pos.get('title') === title)[0];

    pick.setProperties({ position });
    pick.save();
  },


  @action
  submitForm() {
    if (!this.get('submitted')) {
      const willHire = this.get('model.picks').filter(pick => !pick.get('status'));

      willHire.invoke('set', 'status', 'hire');
      willHire.invoke('save');

      this.set('submitted', true);

      willHire.forEach(pick => {
        this.store.createRecord('offer', {
          position: pick.get('position'),
          applicant: pick.get('applicant'),
        })
        .save()
        .then(() => {
          const ajax = this.get('ajax');
          const session = this.get('session');
          let endpoint = url.resolve(config.host, 'api/offer_emails');

          const authorizer = session.session.authenticator.replace(/authenticator/, 'authorizer');

          session.authorize(authorizer, (headerName, header) => {
            const headers = {};
            headers[headerName] = header;
      
            ajax 
            .post(endpoint, { headers })
            .catch(() => {
              this.set('errorMessage', 'Could not send offer emails to applicants');
            });
          });
        });
      });
    }
  }

});
