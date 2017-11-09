import Ember from 'ember';
import Applicant from '../../../models/applicant';
import config from '../../../config/environment';
import url from 'npm:url';
import { computed, action } from 'ember-decorators/object';
import PaginatedController from '../../PaginatedController';


export default PaginatedController.extend({

  lotteryStatus: Ember.inject.service(),
  session: Ember.inject.service(),
  ajax: Ember.inject.service(),

  attributes: Object.values(Ember.get(Applicant, 'attributes')._values),

  searchQuery: '',

  removedFields: [
    'participant_essay', 
    'interests', 
    'user', 
    'offer_status',
    'offer_site',
    'position_id',
    'position_title',
    'updated_at', 
    'created_at'
  ],

  sentEmails: false,
  disableSubmit: false,
  updateStatus: false, 
  lotteryStatOverride: false,
  

  @computed('attributes', 'removedFields')
  attributeNames(attributes, fields) {
    return attributes.filter(x => fields.indexOf(x.name) === -1).map(attr => attr.name.split('_').join(' '));
  },


  @computed('model.expire')
  expireStat(status) { return status; },

  @computed('model.lottery')
  lotteryStat(status) { return status; },

  @computed('model.worker')
  workerStat(status) { return status; },

  @computed('expireStat')
  expireActive(status) { return status.toLowerCase() === 'active'; },

  @computed('lotteryStat', 'lotteryStatOverride')
  lotteryActive(status, override) { return override || status.toLowerCase() === 'active'; },

  @computed('workerStat')
  workerActive(status) { return status.toLowerCase() === 'active'; },


  @computed('expireActive', 'lotteryActive', 'workerActive')
  canRunLottery(expire, lottery, worker) {
    const canRun = ![expire, lottery, worker].any(x => x); 

    if (!canRun) {
      this.setUpdateTimer();
    }

    return canRun;
  },


  @computed('model.applicants.[]', 'searchQuery')
  sortedModel(model, query) {
    let results = model;

    if (query.length > 1) {
      this.resetPage();
      query = query.toLowerCase();

      results = results.filter(x => {
        return x.get('first_name').toLowerCase().startsWith(query) 
               || x.get('last_name').toLowerCase().startsWith(query);
      });
    }

    return results.sortBy('last_name');
  },


  @computed('sortedModel.[]')
  modelLength(sortedModel) { return sortedModel.get('length'); },


  @computed('sortedModel.[]', 'min', 'max', 'removedFields')
  filteredModel(sortedModel, min, max, fields) {
    return sortedModel.slice(min, max).map(x => {
      const json = x.toJSON();
      fields.forEach(field => delete json[field]);

      return json;
    });
  },


  @action
  runLottery() {
    const canRunLottery = this.get('canRunLottery');

    if (canRunLottery && !this.get('disableSubmit')) {
      this.set('disableSubmit', true);
      const ajax = this.get('ajax');
      const session = this.get('session');
      let endpoint = url.resolve(config.host, 'api/matches');

      const authorizer = session.session.authenticator.replace(/authenticator/, 'authorizer');

      session.authorize(authorizer, (headerName, header) => {
        const headers = {};
        headers[headerName] = header;
  
        ajax 
        .post(endpoint, { headers })
        .then(() => {
          this.set('lotteryStatOverride', true);
          this.setUpdateTimer();
        })
        .catch(() => {
          this.set('errorMessage', 'Could not run the current lottery');
        })
        .finally(() => {
          this.set('disableSubmit', false);
        });
      });

     }
  },


  sendOfferEmails() {
    const ajax = this.get('ajax');
    const session = this.get('session');
    const endpoint = url.resolve(config.host, 'api/offer_emails');

    const authorizer = session.session.authenticator.replace(/authenticator/, 'authorizer');

    session.authorize(authorizer, (headerName, header) => {
      const headers = {};
      headers[headerName] = header;

      ajax
      .post(endpoint, { headers })
      .catch(() => {
        this.set('errorMessage', 'Could not send offer emails to matched lottery applicants');
      });
    });
  },


  setUpdateTimer() {
    if (this.get('updateTimer'))  {
      clearTimeout(this.get('updateTimer'));
    }

    const lotteryStatus = this.get('lotteryStatus');

    lotteryStatus.getExpire().then(status => {
      if (
        !this.get('sentEmails')
        && status.toLowerCase() === 'active' 
      ) {
        this.set('sentEmails', true);
        this.sendOfferEmails();
      }

      this.set('expireStat', status);
    });

    lotteryStatus.getLottery().then(status => {
      this.set('lotteryStat', status);
    });

    lotteryStatus.getWorker().then(status => {
      this.set('workerStat', status);
    });

    const timer = setTimeout(() => {
      this.setUpdateTimer();
    }, 5000);

    this.set('updateTimer', timer);
  },

});
