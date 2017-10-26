import Ember from 'ember';
import { action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  session: Ember.inject.service('session'),


  @action
  authenticate()  {
    const { username, password, session } = this.getProperties('username', 'password', 'session');
    
    session.authenticate('authenticator:devise', username, password)
    .catch(reason => {
      this.set('errorMessage', reason.error || reason);
    });
  }

});
