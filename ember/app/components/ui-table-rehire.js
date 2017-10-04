import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    checkboxOnChange(model,value) {
      model.setProperties({ 'should_rehire': value,
                            'has_been_modified': true });
      model.save().then((model) => {
        Ember.run.later(() => {
          model.set('has_been_modified', false);
        }, 3000);
      });
    }
  }
});
