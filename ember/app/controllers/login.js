import Ember from 'ember';
import { action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  session: Ember.inject.service('session'),

  @action
  authenticate()  {
    const { email, password, session } = this.getProperties('email', 'password', 'session');
    
    session.authenticate('authenticator:devise', email, password)
    .catch(reason => {
      this.set('errorMessage', reason.error || reason);
    });
  }

});
