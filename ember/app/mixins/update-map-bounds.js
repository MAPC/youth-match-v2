import Ember from 'ember';
import { action, computed } from 'ember-decorators/object';
import L from 'npm:leaflet';


export default Ember.Mixin.create({

  mapState: Ember.inject.service(),


  /**
   * Members
   */

  hashProperty: null,

  @computed
  modelName() {
    return this.routeName;
  },


  /**
   * Methods
   */

  @action
  didTransition() {
    this.afterModel();
    return this._super();
  },


  afterModel() {
    const mapState = this.get('mapState');
    let applicants = this.modelFor(this.get('modelName')) || [];
    
    if (this.get('hashProperty')) {
      applicants = applicants.get('jobs');
    }

    if (applicants !== undefined) {
      const latLngs = applicants.map(applicant => L.latLng([applicant.get('latitude'), applicant.get('longitude')]));
      mapState.set('bounds', L.latLngBounds(latLngs));
    }

    return this._super();
  }

});
