import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  session: Ember.inject.service(),

  queryParams: ['min', 'max'],
  min: 0,
  max: 50,


  @computed('min', 'max')
  perPage(min, max) {
    if (min > max) {
      this.set('max', min);
      this.set('min', max);
    }
    else if (min === max) {
      this.set('min', 0);
    }

    return this.get('max') - this.get('min');
  },


  @computed('max', 'perPage')
  page(max, perPage) {
    return Math.round(max / perPage);
  },


  @computed('model.[]')
  sortedModel(model) {
    return model.sortBy('email');
  },

  @computed('sortedModel.[]', 'min', 'max', 'session.session.content.authenticated')
  filteredModel(sortedModel, min, max, session) {
    return sortedModel.filter(user => user.get('email') != session.email).slice(min, max);
  },


  @action 
  previous() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');

    let newMin = min - perPage;
    let newMax = max - perPage;

    this.set('min', newMin >= 0 ? newMin : 0);
    this.set('max', newMax >= perPage ? newMax : perPage);
  },


  @action
  next() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('min', min + perPage);
    this.set('max', max + perPage);
  },


  @action
  first() {
    const perPage = this.get('perPage');

    this.set('min', 0);
    this.set('max', perPage);
  },


  @action
  last() {
    let { sortedModel, perPage } = this.getProperties('sortedModel','perPage');
    let count = sortedModel.get('length');

    this.set('min', count - perPage);
    this.set('max', count);
  },


  @action
  setUpdateable(target) {
    const model = this.get('sortedModel');
    const user = model.filter(user => user.id === target.dataset.userid);
    
    if (user) {
      model.removeObject(user);

      user.set('account_type', target.value);
      user.set('updated', true);

      model.pushObject(user);
    }
  },


  @action 
  deleteUser(user) {
    user.destroyRecord();
  },


  @action
  updateUser(user) {
    if (user.updated) {
      console.log(user.account_type);
    }
    else {
      console.log('this user was not updated');
    }
  }



});
