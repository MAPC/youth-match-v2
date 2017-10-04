import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['ui-visibility-sticky'],
  mapState: Ember.inject.service(),
  didInsertElement() {
    Ember.run.next(this, () => {
      var that = this;
      this.$()
        .visibility({
          type   : 'fixed',
          offset : 15,
          onUpdate: that.updateMap(that)
        })
      ;
    })
  },
  updateMap(that) {
    let mapInstance = this.get('mapState.mapInstance.target');
    if(mapInstance) {
      mapInstance.invalidateSize();
      window.map=mapInstance;
    }
  }
});
