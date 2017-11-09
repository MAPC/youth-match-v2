import Ember from 'ember';
import Applicant from '../../../models/applicant';
import { offerStatusMap } from '../../../helpers/offer-status-map';
import { computed } from 'ember-decorators/object';
import PaginatedController from '../../PaginatedController';


export default PaginatedController.extend({

  attributes: Object.values(Ember.get(Applicant, 'attributes')._values),
  searchQuery: '',

  removedFields: [
    'id',
    'participant_essay', 
    'grid_id',
    'interests', 
    'positions',
    'user', 
    'updated_at', 
    'created_at'
  ],
  

  @computed('attributes', 'removedFields')
  attributeNames(attributes, fields) {
    return attributes.filter(x => fields.indexOf(x.name) === -1).map(attr => attr.name.split('_').join(' '));
  },

  @computed('model.offers.[]') 
  offerPositions(offers) {
    return offers.mapBy('position');
  },


  @computed('model.applicants.[]', 'model.offers.@each.position', 'model.positions')
  combinedModel(applicants, offers, positions) {
    const activeApplicants = offers.map(offer => {
      let applicant = offer.get('applicant').toJSON({ includeId: true });
      let position = positions.filter(pos => pos.get('id') === offer.get('position.id'))[0];

      applicant.offer_status = offerStatusMap([offer.get('status')]);
      applicant.offer_site = position.get('site_name');
      applicant.position_title = position.get('title');
      applicant.position_id = position.get('id');

      return applicant;
    });

    const augmentedApplicants = applicants.map(applicant => {
      applicant = applicant.toJSON({ includeId: true });

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
      this.resetPage();

      query = query.toLowerCase();

      results = results.filter(x => {
        return x.first_name.toLowerCase().startsWith(query)
               || x.last_name.toLowerCase().startsWith(query);
      });
    }

    return results.sortBy('last_name');
  },


  @computed('sortedModel.[]')
  modelLength(sortedModel) { return sortedModel.get('length'); },


  @computed('sortedModel.[]', 'min', 'max', 'removedFields')
  filteredModel(sortedModel, min, max, fields) {
    return sortedModel.slice(min, max).map(x => {
      let json = Ember.copy(x);
      fields.forEach(field => delete json[field]);

      return json;
    });
  },

});
