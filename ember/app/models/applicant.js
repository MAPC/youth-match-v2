import Ember from 'ember';
import DS from 'ember-data';
import { truncateText } from '../helpers/truncate-text';
import { computed } from 'ember-decorators/object';

const MAX_POSITIONS_ALLOWED = 10;

export default DS.Model.extend({
  first_name: DS.attr('string'),
  last_name: DS.attr('string'),

  @computed('first_name', 'last_name')
  full_name(first_name, last_name){
    return `${first_name} ${last_name}`;
  },

  email: DS.attr('string'),
  icims_id: DS.attr('number'),
  prefers_nearby: DS.attr('boolean'),
  has_transit_pass: DS.attr('boolean'),
  latitude: DS.attr('number'),
  longitude: DS.attr('number'),
  created_at: DS.attr('date'),
  updated_at: DS.attr('date'),
  lottery_number: DS.attr('number'),
  interests: DS.attr(),
  position_location: DS.attr('string'),
  position_role: DS.attr('string'),  
  grid_id: DS.attr('number'),
  mobile_phone: DS.attr('string'), 
  guardian_name: DS.attr('string'), 
  guardian_phone: DS.attr('string'), 
  guardian_email: DS.attr('string'), 
  neighborhood: DS.attr('string'), 
  in_school: DS.attr('boolean'), 
  school_type: DS.attr('string'), 
  bps_student: DS.attr('boolean'), 
  bps_school_name: DS.attr('string'), 
  current_grade_level: DS.attr('string'), 
  english_first_language: DS.attr('boolean'), 
  first_language: DS.attr('string'), 
  fluent_other_language: DS.attr('boolean'), 
  other_languages: DS.attr(), 
  held_successlink_job_before: DS.attr('boolean'), 
  previous_job_site: DS.attr('string'), 
  site_name: DS.attr('string'),
  wants_to_return_to_previous_job: DS.attr('boolean'), 
  superteen_participant: DS.attr('boolean'), 
  participant_essay: DS.attr('string'), 
  address: DS.attr('string'),  
  home_phone: DS.attr('string'), 
  workflow_id: DS.attr('string'),
  receive_text_messages: DS.attr('boolean'),
  is_returning: DS.attr('boolean'),

  @computed('is_returning')
  isReturning(is_returning) {
    return (is_returning) ? "Yes" : "No";
  },

  @computed('latitude', 'longitude')
  hasGeom(latitude, longitude) {
    return latitude && longitude;
  },

  hasReachedMaxPositions: Ember.computed('positions.[]', function() {
    return this.get('positions.length') >= MAX_POSITIONS_ALLOWED;
  }),

  positions: DS.hasMany('position'),
  picks: DS.hasMany('pick'),

  user: DS.belongsTo({ async: true }),

  isSelected: false,

  @computed('interests')
  truncatedInterests(interests) {
    return truncateText(interests, { limit: 10 })
  }

});

