import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';


export default Ember.Route.extend(AuthenticatedRouteMixin, {

  session: Ember.inject.service(),


  model() {
    const session = this.get('session.session');

    return this.store.query('user', { email: session.content.authenticated.email })
                     .then(users => users.get('firstObject'));
  },


  afterModel(user) {
    const accountType = user.get('account_type');
    const pathSegments = window.location.pathname.split('/');

    if (pathSegments[1] !== 'dashboard' && pathSegments[2] !== accountType) {
      this.transitionTo(`dashboard.${accountType}`);
    }
  },

});
