import Ember from 'ember';
import Applicant from '../../../models/applicant';
import { computed, action } from 'ember-decorators/object';

const additionalAttributes = ['offer_status', 'position_title', 'offer_site', 'position_id']

const defaults = {
  min: 0,
  max: 50,
};

export default Ember.Controller.extend({


  queryParams: ['min', 'max'],
  min: defaults.min,
  max: defaults.max,


  attributes: Object.values(Ember.get(Applicant, 'attributes')._values)
                    .concat(additionalAttributes.map(x => {return {name: x};})),

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

  @computed('model.applicants.[]', 'model.offers.[]')
  combinedModel(applicants, offers) {
    const activeApplicants = offers.map(offer => {
      let applicant = offer.get('applicant').toJSON();
      let position = offer.get('position').toJSON();

      applicant.offer_status = offer.get('status');
      applicant.offer_site = position.site_name;
      applicant.position_id = position.id;
      applicant.position_title = position.title;

      return applicant;
    });

    const augmentedApplicants = applicants.map(applicant => {
      applicant = applicant.toJSON();

      applicant.offer_status = 'No Offer';
      applicant.offer_site = null;
      applicant.position_id = null;
      applicant.position_title = null;

      return applicant;
    });

    const activeIds = activeApplicants.map(applicant => applicant.id);
    const filtered = augmentedApplicants.filter(applicant => activeIds.indexOf(applicant.id) === -1);

    return filtered.concat(activeApplicants);
  },


  @computed('combinedModel.[]', 'searchQuery')
  sortedModel(model, query) {
    let results = model;
    
    if (query.length > 1) {
      this.set('min', defaults.min);
      this.set('max', defaults.max);

      results = results.filter(x => {
        return x.first_name.toLowerCase().startsWith(query)
               || x.last_name.toLowerCase().startsWith(query);
      });
    }

    return results.sortBy('last_name');
  },


  @computed('sortedModel.[]', 'min', 'max', 'removedFields')
  filteredModel(sortedModel, min, max, fields) {
    return sortedModel.slice(min, max).map(x => {
      let json = Ember.copy(x);
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


});
