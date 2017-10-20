import Ember from 'ember';

export default Ember.Route.extend({

  redirect() {
    this.transitionTo('dashboard.partner.positions');
  }

});
