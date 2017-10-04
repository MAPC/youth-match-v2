import DS from 'ember-data';

export default DS.JSONAPISerializer.extend({
  keyForAttribute(key) {
    return key;
  },
  attrs: {
    latitude: {serialize: false},
    longitude: {serialize: false}
  }
});
