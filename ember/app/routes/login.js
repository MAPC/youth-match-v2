import Ember from 'ember';
import UnauthenticatedRouteMixin from 'ember-simple-auth/mixins/unauthenticated-route-mixin';

export default Ember.Route.extend(UnauthenticatedRouteMixin, {

  session: Ember.inject.service(),

  queryParams: { 
    token: '',
    email: '',
  },

  model(params) {
    if (params.email && params.token) {
      this.get('session.session').authenticate('authenticator:token', params.email, params.token);
    }
  }
  

});
