import Ember from 'ember';
import { nest } from 'd3-collection';
import { flatten } from '../../../helpers/flatten';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  mapState: Ember.inject.service(),


  /**
   * Members
   */

  fields: ['site_name', 'title', 'open_positions', 'category'],
  queryParams: ['min','max'],
  min: 0,
  max: 9,
  perPage: 9,
  selectedInterestCategories: null,
  resource: 'dashboard.youth.jobs',


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
    this.transitionToRoute('dashboard.youths.jobs.job', model.id);
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
  linkToApplicant(job) {
    this.transitionToRoute('dashboard.youth.jobs.job', job.id);
  },


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
  },
  

});
