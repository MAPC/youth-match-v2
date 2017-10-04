import Ember from 'ember';

export function isNotEmpty(params/*, hash*/) {
  let type = Ember.typeOf(params[0]);
  return (type !== 'undefined') && (type !== 'null');
}

export default Ember.Helper.helper(isNotEmpty);
