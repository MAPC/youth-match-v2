import Ember from 'ember';

export function attributeType(params/*, hash*/) {
  let attribute = params[0];

  return Ember.typeOf(attribute);
}

export default Ember.Helper.helper(attributeType);
