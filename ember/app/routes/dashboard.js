import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Ember.Route.extend(AuthenticatedRouteMixin, {

  session: Ember.inject.service(),


  model() {
    const session = this.get('session.session');

    return this.store.query('user', { email: session.content.authenticated.email })
                     .then(users => users.get('firstObject'));
  },

});
