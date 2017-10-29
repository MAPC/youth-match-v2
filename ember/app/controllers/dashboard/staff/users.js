import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';

const defaults = {
  min: 0,
  max: 50,
};

export default Ember.Controller.extend({

  ajax: Ember.inject.service(),

  loading: true,
  threshold: 1,

  updated: false,
  updateMessage: '',

  searchQuery: '',

  queryParams: ['min', 'max'],
  min: defaults.min,
  max: defaults.max,


  @computed('min', 'max')
  perPage(min, max) {
    if (min > max) {
      this.set('max', min);
      this.set('min', max);
    }
    else if (min === max) {
      this.set('min', defaults.min);
    }

    return this.get('max') - this.get('min');
  },


  @computed('max', 'perPage')
  page(max, perPage) {
    return Math.round(max / perPage);
  },


  @computed('model.[]', 'searchQuery')
  sortedModel(model, query) {
    if (model.get('length') > this.get('threshold')) {
      this.set('loading', false);
    }

    let results = model;

    if (query.length > 1) {
      this.set('min', defaults.min);
      this.set('max', defaults.max);

      query = query.toLowerCase();

      results = results.filter(x => x.get('email').toLowerCase().startsWith(query));
    }

    return results.sortBy('email');
  },


  @computed('sortedModel', 'min', 'max')
  filteredModel(sortedModel, min, max) {
    return sortedModel.slice(min, max);
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
  regeneratePassword(user) {
    console.log(user.get('id'));

    const ajax = this.get('ajax');

    //ajax.post();
  },



});
