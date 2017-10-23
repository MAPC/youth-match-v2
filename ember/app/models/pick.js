import DS from 'ember-data';

const { belongsTo, attr } = DS;

export default DS.Model.extend({
  applicant: belongsTo('applicant'),
  position: belongsTo('position'),
  applicant_status: attr('string'),
  partner_status: attr('string'),
});
