import Ember from 'ember';
import DS from 'ember-data';
import RSVP from 'rsvp';
import { computed } from 'ember-decorators/object';

export default DS.Model.extend({
  first_name: DS.attr('string'),
  last_name: DS.attr('string'),
  applicant: DS.belongsTo('applicant', { async: true }),
  positions: DS.hasMany('position'),
  applicant_interests: DS.attr('json-null-to-empty'),
  allocation_rule: DS.attr('number', { defaultValue: 2 }),
  
  picks_count: Ember.computed('positions.@each.picks', function() {
    return this.get('positions').then(positions=> {
      return RSVP.all(positions.invoke('get', 'picks')).then(picks=> {
        console.log(picks);
        return picks.mapBy('length').reduce((num, cur, i) => { return num+cur; },0);
      });
    })
  }),
  
  @computed('positions')
  site_name(positions) {
    return positions.uniqBy('site_name').get('firstObject');
  }
});
