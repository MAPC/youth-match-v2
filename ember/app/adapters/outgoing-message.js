import DS from 'ember-data';
import config from '../config/environment';
import ApplicationAdapter from './application';

export default OutgoingMessageAdapter.extend({
  namespace: '/api',
  host: Ember.computed(() => { return config.host || '/'; }),
  pathForType(type) {
    return Ember.String.underscore(type) + 's';
  },
  keyForAttribute(key) {
    return key;
  }
});
