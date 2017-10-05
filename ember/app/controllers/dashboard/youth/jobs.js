import Ember from 'ember';
import { nest } from 'd3-collection';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  mapState: Ember.inject.service(),


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
  }

});
