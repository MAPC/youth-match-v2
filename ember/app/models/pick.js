import DS from 'ember-data';

const { belongsTo, attr } = DS;

export default DS.Model.extend({
  applicant: belongsTo('applicant'),
  position: belongsTo('position'),
  status: attr('string'),
});
