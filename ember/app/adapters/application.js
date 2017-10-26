import Ember from 'ember';
import DS from 'ember-data';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';
import config from '../config/environment';
import { computed } from 'ember-decorators/object';

export default DS.JSONAPIAdapter.extend(DataAdapterMixin, {
  session: Ember.inject.service(),

  @computed('session.session')
  authorizer(session) {
    return session.authenticator.replace(/authenticator/, 'authorizer');
  },

  host: config.host,
  namespace: 'api',
});
