import Ember from 'ember';
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


  @action
  removePosition(positionId) {
    const applicantId = this.get('model.user.applicant.id');
    const position = this.get('model.positions').findBy('id', positionId);
    const applicant = position.get('applicants').findBy('id', applicantId);

    position.get('applicants').removeObject(applicant);
    position.save();
  },


});
