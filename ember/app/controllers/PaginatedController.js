import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  queryParams: ['min', 'max'],

  defaultMin: 0,
  defaultMax: 50,

  /**
   * This attribute must be overriden in order for the controller
   * to work properly.
   */
  @computed('defaultMax')
  modelLength(def) { return def; },

  @computed('defaultMin')
  min(def) { return def; },

  @computed('defaultMax')
  max(def) { return def; },

  @computed('min', 'max', 'defaultMin')
  perPage(min, max, defaultMin) {
    if (min > max) {
      this.set('max', min);
      this.set('min', max);
    }
    else if (min === max) {
      this.set('min', defaultMin);
    }

    return this.get('max') - this.get('min');
  },


  @computed('max', 'perPage')
  page(max, perPage) {
    return Math.round(max / perPage);
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
    const { modelLength, perPage } = this.getProperties('modelLength','perPage');

    this.set('min', modelLength - perPage);
    this.set('max', modelLength);
  },

  resetPage() {
    this.set('min', this.get('defaultMin'));
    this.set('max', this.get('defaultMax'));
  }

});
