import DS from 'ember-data';

export default DS.Model.extend({
  status: DS.attr('string'),
  position: DS.belongsTo('position'),
  applicant: DS.belongsTo('applicant', {async: true })
});
