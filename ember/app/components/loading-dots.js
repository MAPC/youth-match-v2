import Ember from 'ember';
import { computed } from 'ember-decorators/object';


export default Ember.Component.extend({

  classNames: ['component', 'loading-dots'],
  threshold: 0,
  model: [],

  @computed('model.[]', 'threshold')
  finishedLoading(model, threshold) {
    return model.length > threshold;
  }

});
