import Ember from 'ember';
import config from '../config/environment';
import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  host: Ember.computed(() => { return config.host || '/'; }),
  namespace: '/api',
  keyForAttribute(key) {
    return key;
  }
});
