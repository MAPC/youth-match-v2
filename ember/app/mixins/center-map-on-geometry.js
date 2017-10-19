import Ember from 'ember';

export default Ember.Mixin.create({
  mapState: Ember.inject.service(),
  modelForRoute: Ember.computed(function() {
    return this.routeName;
  }),
  hashProperty: '',
  positionMap() {
    let mapState = this.get('mapState');
    let model = this.modelFor(this.get('modelForRoute'));

    if (this.get('hashProperty')) {
      model = model[this.get('hashProperty')];
    }

    let lat = model.get('latitude');
    let lng = model.get('longitude');
    let zoom = 18;
    model.set('isSelected', true);
    if (mapState.get('mapInstance')) {
      Ember.run.next(()=> {
        mapState.get('mapInstance').panTo([lat,lng]);
        Ember.run.later(()=> {
          mapState.get('mapInstance').setZoom(18);
        }, 250)
      });
    }
    mapState.setProperties({
      lat,
      lng,
      zoom
    });
  },
  actions: {
    didTransition() { 
      this.positionMap();
      return this._super();
    },
    willTransition() {
      let model = this.modelFor(this.get('modelForRoute'));
      if (this.get('hashProperty')) {
        model = model[this.get('hashProperty')];
      }
      model.set('isSelected', false);
      return this._super();
    }
  }
});
