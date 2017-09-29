import DS from 'ember-data';
import Ember from 'ember';
import { computed } from 'ember-decorators/object';
import { collectionAction } from 'ember-api-actions';

export default DS.Model.extend({
  latitude: DS.attr('number'),
  longitude: DS.attr('number'),
  category: DS.attr('string'),
  site_name: DS.attr('string'),
  title: DS.attr('string'),
  external_application_url: DS.attr('string'),
  primary_contact_person: DS.attr('string'),
  primary_contact_person_title: DS.attr('string'),
  primary_contact_person_email: DS.attr('string'),
  address: DS.attr('string'),
  primary_contact_person_phone: DS.attr('string'),
  site_phone: DS.attr('number'),
  duties_responsbilities: DS.attr('string'),
  ideal_candidate: DS.attr('string'),
  neighborhood: DS.attr('string'),
  owned: collectionAction({
    path: 'owned',
    type: 'get',
    urlType: 'findRecord'
  }),
  open_positions: DS.attr('number', { defaultValue: 0 }),
  applicants: DS.hasMany('applicant'),
  requisitions: DS.hasMany('requisition'),
  picks: DS.hasMany('pick'),

  isSelected: false,

  @computed('external_application_url')
  hasExternalApp(external_application_url) {
    return !Ember.isEmpty(external_application_url);
  },

});
