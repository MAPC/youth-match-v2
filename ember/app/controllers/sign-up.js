import Ember from 'ember';
import { action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  session: Ember.inject.service(),


  @action
  createAccount() {
    const { email, password, passwordConfirm } = this.getProperties('email', 'password', 'passwordConfirm');

    if (password !== passwordConfirm) {
      this.set('errorMessage', 'Passwords do not match');
    }
    else {
      const newUser = this.get('model');
      
      newUser.set('email', email);
      newUser.set('password', password);

      newUser
      .save()
      .then(() => {
        const session = this.get('session');

        session
        .authenticate('authenticator:devise', email, password)
        .catch(reason => {
          this.set('errorMessage', reason.error || reason);
        });
      })
      .catch(error => {
        this.set('errorMessage', error);
      });
    }
  }

});
