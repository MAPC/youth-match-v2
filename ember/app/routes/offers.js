import Ember from 'ember';
import url from 'npm:url';
import querystring from 'npm:querystring';
import config from '../config/environment';

export default Ember.Route.extend({

  ajax: Ember.inject.service(),

  queryParams: {
    email: '',
    token: '',
    response: false,
  },

  beforeModel(transition) {
    const queryParams = transition.queryParams;
    const { email, token, response } = queryParams;

    if (email && token && response) {
      const queries = querystring.stringify(queryParams);
      const endpoint = url.resolve(config.host, `offers/answer?${queries}`);

      this.get('ajax')
      .request(endpoint)
      .finally(() => {
        delete queryParams.response;
        this.transitionTo('login', { queryParams });
      });
    }
    else {
      this.transitionTo('login');
    }
  }

});
