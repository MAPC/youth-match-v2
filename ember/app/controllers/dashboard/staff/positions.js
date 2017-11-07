import Ember from 'ember';
import Position from '../../../models/position';
import { computed, action } from 'ember-decorators/object';
import PaginatedController from '../../PaginatedController';


export default PaginatedController.extend({

  attributes: Object.values(Ember.get(Position, 'attributes')._values),
  searchQuery: '',

  renamedFields: {
    'open_positions': 'allotted_positions',
  },

  removedFields: [
    'applicants',
  ],


  @computed('sortedModel.[]')
  modelLength(sortedModel) { return sortedModel.get('length'); },


  @computed('attributes', 'removedFields', 'renamedFields')
  attributeNames(attributes, fields, renamedFields) {
    return attributes.filter(x => fields.indexOf(x.name) === -1)
                     .map(attr => renamedFields[attr.name] || attr.name)
                     .map(attrName => attrName.split('_').join(' '));
  },


  @computed('model.[]', 'searchQuery')
  sortedModel(model, query) {
    let results = model.map(x => x.toJSON());

    if (query.length > 1) {
      this.set('min', defaults.min);
      this.set('max', defaults.max);

      query = query.toLowerCase();

      results = results.filter(x => {
        return (x.primary_contact_person_email && x.primary_contact_person_email.toLowerCase().startsWith(query))
               || (x.site_name && x.site_name.toLowerCase().startsWith(query));
      });
    }

    return results.sortBy('last_name');
  },


  @computed('sortedModel.[]', 'min', 'max', 'removedFields')
  filteredModel(sortedModel, min, max, fields) {
    return sortedModel.slice(min, max).map(x => {
      const json = Ember.copy(x);
      fields.forEach(field => delete json[field]);

      return json;
    });
  },


});
