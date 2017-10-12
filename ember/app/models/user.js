import Ember from 'ember';
import DS from 'ember-data';
import RSVP from 'rsvp';
import { computed } from 'ember-decorators/object';

const { attr } = DS;

export default DS.Model.extend({
  email: attr('string'),
  password: attr('string'),

  first_name: DS.attr('string'),
  last_name: DS.attr('string'),
  applicant: DS.belongsTo('applicant', { async: true }),
  positions: DS.hasMany('position'),
  applicant_interests: DS.attr('json-null-to-empty'),
  allocation_rule: DS.attr('number', { defaultValue: 2 }),
  account_type: DS.attr('string'),
  
  picks_count: Ember.computed('positions.@each.picks', function() {
    return this.get('positions').then(positions=> {
      return RSVP.all(positions.invoke('get', 'picks')).then(picks=> {
        return picks.mapBy('length').reduce((num, cur) => { return num+cur; },0);
      });
    })
  }),
  
  @computed('positions')
  site_name(positions) {
    return positions.uniqBy('site_name').get('firstObject');
  }
});
