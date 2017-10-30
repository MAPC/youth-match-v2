import DS from 'ember-data';
const { belongsTo, attr } = DS;

export default DS.Model.extend({
  applicant: belongsTo('applicant', { async: false }),
  position: belongsTo('position'),
  accepted: attr('string'),
});
