import OAuth2PasswordGrant from 'ember-simple-auth/authenticators/oauth2-password-grant';

export default OAuth2PasswordGrant.extend({

  authenticate(email, token) {
    return new Promise((resolve, reject) => {
      resolve({
        email,
        access_token: token,
        token_type: 'bearer',
      });
    });
  }

});
