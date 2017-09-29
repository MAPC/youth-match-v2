import Devise from 'ember-simple-auth/authenticators/devise';
import config from '../config/environment';
import url from 'npm:url';

export default Devise.extend({
  serverTokenEndpoint: url.resolve(config.host, 'users/sign_in')
});
