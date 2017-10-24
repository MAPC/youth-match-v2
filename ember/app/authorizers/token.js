import BaseAuthorizer from 'ember-simple-auth/authorizers/base';


export default BaseAuthorizer.extend({

  authorize(data, block) {
    if (data.email && data.access_token) {
      block('Authorization', `Token token=${data.access_token}, email=${data.email}`);
    }
  }
  
});
