import Ember from 'ember';
import { flatten } from '../../../../helpers/flatten';
import { computed, action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  dashboardYouthJobs: Ember.inject.controller('dashboard.youth.jobs'),

  /**
   * Members
   */

  queryParams: ['min', 'max'],
  min: 0,
  max: 10,


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


  @computed('dashboardYouthJobs.filteredModel')
  filteredModel(model) {
    return model;
  },


  @computed('filteredModel', 'min', 'max')
  sortedModel(filteredModel, min, max) {
    return filteredModel.sortBy('site_name').slice(min, max);
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
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('min', 0);
    this.set('max', perPage);
  },


  @action
  last() {
    let { filteredModel, perPage } = this.getProperties('filteredModel','perPage');
    let count = filteredModel.get('length');
    this.set('min', count - perPage);
    this.set('max', count);
  },


});
