import Ember from 'ember';

export default Ember.Component.extend({
  items: Ember.computed('model', 'fields', function() {
    let { model, fields } = this.getProperties('model', 'fields');
    
    return model.getProperties(fields);
  })
});
