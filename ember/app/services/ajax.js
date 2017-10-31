import Ember from 'ember';
import AjaxService from 'ember-ajax/services/ajax';
import { computed } from 'ember-decorators/object';


export default AjaxService.extend({

  session: Ember.inject.service(),

  @computed('session.authToken')  
  headers: {
    get(authToken) {
      let headers = {}; 

      if (authToken) {
        headers['auth-token']  = authToken;
      }

      return headers;
    }
  }

});
