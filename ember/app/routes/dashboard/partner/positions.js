import Ember from 'ember';


export default Ember.Route.extend({

  model() {
    return this.modelFor('dashboard.partner');
  },

  afterModel(model) {
    console.log(model);
  }

});
