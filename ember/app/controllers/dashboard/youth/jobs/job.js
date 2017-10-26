import Ember from 'ember';
import { nest } from 'd3-collection';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  mapState: Ember.inject.service(),

  fields: ['site_name', 'latitude', 'longitude'],


  @computed('model.user', 'model.position', 'model.position.applicants.@each.id')
  isInterested: {
    get(user, position) {
      let applicant = user.get('applicant');
      return position.get('applicants').isAny('id', applicant.get('id'));
    },

    set(value, user, position) {
      user.get('applicant').then((applicant) => {
        if (value) {
          if (!applicant.get('hasReachedMaxPositions')) {
            position.get('applicants').pushObject(applicant);
            position.save();
          }
        } 
        else {
          position.get('applicants').removeObject(applicant);
          position.save();
        }
      });
    }
  },


  @action
  removePosition(positionId) {
    const applicantId = this.get('model.user.applicant.id');
    const position = this.get('model.positions').findBy('id', positionId);
    const applicant = position.get('applicants').findBy('id', applicantId);

    position.get('applicants').removeObject(applicant);
    position.save();
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
  toggleInterest() {
    this.toggleProperty('isInterested');
  },


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

});
