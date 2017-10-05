import Ember from 'ember';
import { flatten } from '../../../../helpers/flatten';
import { computed, action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  /**
   * Members
   */

  fields: ['site_name', 'title', 'open_positions', 'category'],
  queryParams: ['min','max'],
  min: 0,
  max: 9,
  perPage: 9,
  selectedInterestCategories: null,
  resource: 'dashboard.youth.jobs.index',


  @computed('min','max','perPage')
  page(min,max,perPage) {
    return Math.round(max/perPage);
  },


  @computed('model.positions')
  interestCategories(positions) {
    return flatten(positions.mapBy('category')).uniq();
  },


  @computed('model', 'selectedInterestCategories.[]')
  filteredModel(model,selectedInterestCategories) {
    return model.jobs.filter((el) => {
      return selectedInterestCategories.includes(el.get('category'));
    });
  },


  @computed('filteredModel','min','max','perPage')
  sortedModel(filteredModel,min,max) {
    return filteredModel.sortBy('site_name').slice(min,max);
  },


  /**
   * Methods
   */

  @action 
  previous() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('transition', 'toDown');
    this.set('min', min - perPage);
    this.set('max', max - perPage);
  },


  @action
  next() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('transition', 'toUp');
    this.set('min', min + perPage);
    this.set('max', max + perPage);
  },


  @action
  first() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('transition', 'toDown');
    this.set('min', 0);
    this.set('max', perPage);
  },


  @action
  last() {
    let { filteredModel, perPage } = this.getProperties('filteredModel','perPage');
    let count = filteredModel.get('length');
    this.set('transition', 'toUp');
    this.set('min', count - perPage);
    this.set('max', count);
  },


  @action
  addInterest(interest) {
    this.send('first');
    this.get('selectedInterestCategories').pushObject(interest);
  },


  @action
  removeInterest(interest) {
    this.send('first');
    this.get('selectedInterestCategories').removeObject(interest);
  }

});
