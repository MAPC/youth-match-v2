import Ember from 'ember';

export function pureTitle(params) {
  return params[0].split(': ')[1];
}

export default Ember.Helper.helper(pureTitle);
