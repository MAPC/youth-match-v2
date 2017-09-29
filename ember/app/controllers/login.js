import Ember from 'ember';

export default Ember.Controller.extend({

  session: Ember.inject.service('session'),

  actions: {
    authenticate()  {
      const { email, password, session } = this.getProperties('email', 'password', 'session');
      
      session.authenticate('authenticator:devise', email, password)
      .catch(reason => {
        this.set('errorMessage', reason.error || reason);
      });
    }
  }

});
