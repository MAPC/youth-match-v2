import DS from 'ember-data';

export default DS.Model.extend({
  site_name: DS.attr('string'),
  person_name: DS.attr('string'),
  should_rehire: DS.attr('boolean'),
  has_been_modified: false
});
