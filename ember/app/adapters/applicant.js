import Ember from 'ember';
import config from '../config/environment';
import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  namespace: '/api',
  host: Ember.computed(() => { return config.host || '/'; }),
  pathForType(type) {
    return Ember.String.underscore(type) + 's';
  },
  keyForAttribute(key) {
    return key;
  }
});
