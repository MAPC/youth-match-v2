import Ember from 'ember';
import config from '../config/environment';
import url from 'npm:url';


export default Ember.Service.extend({

  ajax: Ember.inject.service(),
  

  getExpire() {
    return this.get('ajax').request(url.resolve(config.host, 'api/expire-lottery-status'), { dataType: 'text' });
  },

  getLottery() {
    return this.get('ajax').request(url.resolve(config.host, 'api/match-lottery-status'), { dataType: 'text' });
  },

  getWorker() {
    return this.get('ajax').request(url.resolve(config.host, 'api/workers-status'), { dataType: 'text' });
  }
  

});
