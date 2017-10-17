import Ember from 'ember';
import { nest } from 'd3-collection';
import { flatten } from '../../../../helpers/flatten';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  mapState: Ember.inject.service(),


  /**
   * Members
   */

  fields: ['site_name', 'title', 'open_positions', 'category'],
  queryParams: ['min', 'max'],
  selectedInterestCategories: [],
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


  @computed('model.positions')
  interestCategories(positions) {
    return flatten(positions.mapBy('category')).uniq().sort();
  },


  @computed('model', 'selectedInterestCategories.[]')
  filteredModel(model,selectedInterestCategories) {
    return model.positions.filter((el) => {
      return selectedInterestCategories.includes(el.get('category'));
    });
  },


  @computed('filteredModel', 'min', 'max')
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
            .map((row) => {   row.latitude = row.values[0].get('latitude');
                              row.longitude = row.values[0].get('longitude');
                              row.hasManyJobs = (row.values.length > 1);
                              // is a job within the cluster selected?
                              row.isSelected = row.values.mapBy('isSelected').includes(true);
                              return row;  });
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
