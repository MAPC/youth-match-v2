import Ember from 'ember';

export default Ember.Route.extend({

  model() {
    return this.store.query('applicant', { chosen: true });
  },

  afterModel(model) {
    console.log(model);
  }

});
