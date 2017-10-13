import Ember from 'ember';
import Applicant from '../../../models/applicant';
import { computed, action } from 'ember-decorators/object';

export default Ember.Controller.extend({

  queryParams: ['min', 'max'],
  min: 0,
  max: 50,

  attributes: Object.values(Ember.get(Applicant, 'attributes')._values),

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
    return model.sortBy('last_name');
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
  valueChanged(applicant, value, event) {
    console.log(applicant, value, event);
  },


  @action
  verifyField(attribute, event) {
    const target = event.target;
    const value = target.value;
    const type = this.getType(attribute);
    
    console.log(type);
  },

  getType(attribute) {
    const attributes = this.get('attributes');
    let type = attributes.filter(attr => attr.name === attribute)[0].type;

    if (type === 'string') {
      const lower = attribute.toLowerCase();

      ['email', 'phone', 'address'].some(altType => {
        var isType = lower.indexOf(altType) !== -1;
        if (isType) type = altType;
        return isType;
      });
    }

    return type;
  }

});
