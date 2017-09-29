import DS from 'ember-data';

export default DS.Model.extend({
  applicant: DS.belongsTo('applicant'),
  position: DS.belongsTo('position'),
  status: DS.attr('string')
});
