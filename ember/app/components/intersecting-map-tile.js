import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['ui circular bordered image'],
  tagName: 'img',
  attributeBindings: ['src'],
  src: Ember.computed('layerPointx','layerPointy', function() {
    let { layerPointz,layerPointx,layerPointy } = this.getProperties('layerPointz','layerPointx','layerPointy');
    return `http://c.basemaps.cartocdn.com/light_all/${layerPointz}/${layerPointx}/${layerPointy}.png`;
  }),
  lat: null,
  lng: null,
  isGeographic: Ember.computed('lat','lng', function() {
    let { lat, lng } = this.getProperties('lat','lng');
    return (lat && lng);
  }),
  mapState: Ember.inject.service(),
  didInsertElement() {
    let { mapState,isGeographic,lat,lng } = this.getProperties('mapState','isGeographic','lat','lng');

    if (isGeographic) {
      let layerPoint = mapState.mapInstance.target.project([lat,lng]).divideBy(256).floor(),
          { x, y } = layerPoint,
          layerPointz = mapState.mapInstance.target.getZoom();

      this.setProperties({
        layerPointx: x,
        layerPointy: y,
        layerPointz: layerPointz
      });
    }
  }
});
