import Ember from 'ember';
import { nest } from 'd3-collection';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  mapState: Ember.inject.service(),


  /**
   * Members
   */

  @computed('model.positions')
  source(positions) {
    return positions.map(position => {
      return {
        id: position.get('id'),
        title: `${position.get('site_name')} (${position.get('category')})`,
        description: `${position.get('category')}, ${position.get('neighborhood')}`,
      };
    });
  },


  @computed('model.jobs.[]', 'model.jobs.@each.isSelected')
  clusters(positions) {
     const grouped = nest().key(row => row.get('site_name'))
                           .entries(positions.toArray())
                           .map(row => {
                             row.latitude = row.values[0].get('latitude');
                             row.longitude = row.values[0].get('longitude');
                             row.hasManyJobs = row.values.length > 1;
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
    this.transitionToRoute('youth.job', model.id);
  },


  @action
  setMapInstance(map) {
    this.set('mapState.mapInstance', map.target);
  },


  @action
  resetMap(map) {
    Ember.run.next(() => {
      map.target.invalidateSize();
    });
  },


  @action
  linkToApplicant(job) {
    this.transitionToRoute('youth.job', job.id);
  },



});
