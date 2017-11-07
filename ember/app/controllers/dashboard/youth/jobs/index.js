import Ember from 'ember';
import { nest } from 'd3-collection';
import { flatten } from '../../../../helpers/flatten';
import { computed, action } from 'ember-decorators/object';
import PaginatedController from '../../../PaginatedController';


export default PaginatedController.extend({

  mapState: Ember.inject.service(),


  /**
   * Members
   */

  selectedInterestCategories: [],

  max: 10,

  searchQuery: '',


  @computed('model.positions')
  interestCategories(positions) {
    return flatten(positions.mapBy('category')).uniq().sort();
  },


  @computed('model.positions', 'selectedInterestCategories.[]', 'searchQuery')
  filteredModel(positions, selectedInterestCategories, query) {
    let results = positions.filter((el) => {
      return selectedInterestCategories.includes(el.get('category'));
    });

    if (query.length > 1) {
      results = results.length ? results : positions; // use all positions if not filtered by category
      query = query.toLowerCase();


      results = results.filter(position => {
        return (('' + position.get('title')).toLowerCase().startsWith(query))
               || (('' + position.get('site_name')).toLowerCase().startsWith(query));
      });
    }

    return results;
  },


  @computed('filteredModel.[]')
  modelLength(filteredModel) { return filteredModel.get('length'); },


  @computed('filteredModel.[]', 'min', 'max')
  sortedModel(filteredModel, min, max) {

    return filteredModel.sortBy('site_name').slice(min, max);
  },


  @computed('model.positions')
  source(positions) {
    return positions.map((el) => { 
      return {
        id: el.get('id'), 
        title: `${el.get('site_name')} (${el.get('category')})`, 
        description: `${el.get('category')}, ${el.get('neighborhood')}`,
      };
    });
  },


  // this shoud be made into its own model at some point
  @computed('model.positions.[]', 'model.positions.@each.isSelected')
  clusters(positions) {
    let grouped = 
      nest().key((row) => { return row.get('site_name') })
            .entries(positions.toArray())
            .map((row) => {   
              row.latitude = row.values[0].get('latitude');
              row.longitude = row.values[0].get('longitude');
              row.hasManyJobs = (row.values.length > 1);

              // is a job within the cluster selected?
              row.isSelected = row.values.mapBy('isSelected').includes(true);

              return row;  
            });

    return grouped;
  },



  /**
   * Methods
   */


  @action
  linkTo(model, event) {
    event.target.bringToFront();
    this.transitionToRoute('dashboard.youth.jobs.job', model.id);
  },


  @action
  setMapInstance(map) {
    this.set('mapState.mapInstance', map.target);
  },


  @action
  resetMap(map) {
    Ember.run.next(()=> {
      map.target.invalidateSize();
    }); 
  },


  @action
  linkToApplicant(position) {
    this.transitionToRoute('dashboard.youth.jobs.job', position.id);
  },



  @action
  addInterest(interest) {
    this.first();
    this.get('selectedInterestCategories').pushObject(interest);
  },


  @action
  removeInterest(interest) {
    this.first();
    this.get('selectedInterestCategories').removeObject(interest);
  },


  @action
  removePosition(positionId) {
    const applicantId = this.get('model.user.applicant.id');
    const position = this.get('model.positions').findBy('id', positionId);
    const applicant = position.get('applicants').findBy('id', applicantId);

    position.get('applicants').removeObject(applicant);
    position.save();
  }


});
