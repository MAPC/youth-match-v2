import Ember from 'ember';
import { computed } from 'ember-decorators/object';


export default Ember.Controller.extend({

  @computed('model.picks.[]')
  numberChosen(picks) {
    return picks.get('length');
  },

  @computed('model.positions')
  totalAllotments(positions) {
    return positions.get('firstObject.open_positions');
  },


  @computed('totalAllotments', 'model.user.allocation_rule')
  directSelectAllotments(totalAllotments, allocationRule) {
    return Math.floor(totalAllotments / allocationRule);
  },


  @computed('numberChosen', 'directSelectAllotments')
  hasHitLimit(numberChosen, directSelectAllotments) {
    return numberChosen >= directSelectAllotments;
  },

});
