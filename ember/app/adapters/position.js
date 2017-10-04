import DS from 'ember-data';
import config from '../config/environment';
import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  namespace: '/api',
  host: Ember.computed(() => { return config.host || '/'; }),
  keyForAttribute(key) {
    return key;
  }
});
