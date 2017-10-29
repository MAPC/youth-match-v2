import Ember from 'ember';
import Applicant from '../../../models/applicant';
import config from '../../../config/environment';
import { default as _url } from 'npm:url';
import { computed, action } from 'ember-decorators/object';


const defaults = {
  min: 0,
  max: 50,
};

export default Ember.Controller.extend({

  queryParams: ['min', 'max'],
  min: defaults.min,
  max: defaults.max,

  attributes: Object.values(Ember.get(Applicant, 'attributes')._values),

  searchQuery: '',

  removedFields: [
    'participant_essay', 
    'interests', 
    'user', 
    'updated_at', 
    'created_at'
  ],
  

  @computed('attributes', 'removedFields')
  attributeNames(attributes, fields) {
    return attributes.filter(x => fields.indexOf(x.name) === -1).map(attr => attr.name.split('_').join(' '));
  },


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
    let results = model;

    if (query.length > 1) {
      this.set('min', defaults.min);
      this.set('max', defaults.max);

      query = query.toLowerCase();

      results = results.filter(x => {
        return x.get('first_name').toLowerCase().startsWith(query) 
               || x.get('last_name').toLowerCase().startsWith(query);
      });
    }

    return results.sortBy('last_name');
  },


  @computed('sortedModel.[]', 'min', 'max', 'removedFields')
  filteredModel(sortedModel, min, max, fields) {
    return sortedModel.slice(min, max).map(x => {
      const json = x.toJSON();
      fields.forEach(field => delete json[field]);

      return json;
    });
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
  runLottery() {
    const ajax = this.get('ajax');
    const url = _url.resolve(config.host, 'api/matches');

    ajax
    .post({ url })
    .then(result => {
      console.log(result);
    })
    .catch(() => {
      this.set('errorMessage', 'Could not run the current lottery');
    });
  }

});
