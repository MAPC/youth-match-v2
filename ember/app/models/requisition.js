import DS from 'ember-data';

export default DS.Model.extend({
  partner_status: DS.attr('string'),
  applicant_status: DS.attr('string'),
  position: DS.belongsTo('position'),
  applicant: DS.belongsTo('applicant', {async: true })
});
