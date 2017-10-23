import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';
import { math, divide } from 'ember-awesome-macros';


export default Ember.Controller.extend({

  fields: [ 
    'applicant.first_name',
    'applicant.last_name',
    'position.title',
    'status' 
  ],

  applicants_fields: [  
    'first_name',
    'last_name',
    'email',
    'mobile_phone' 
  ],

  @computed('model.applicants')
  source(applicants) {
    return applicants.map((el) => { 
      return {  title:       `${el.get('first_name')} ${el.get('last_name')}`, 
                id:          el.get('id'), 
                description: el.get('interests').join(', ') }; 
    });
  },

  @computed('model.picks.[]')
  pickedApplicants(picks) {
    return picks.mapBy('applicant');
  },

  @computed('model.picks.[]')
  numberChosen(picks) {
    return picks.get('length');
  },

  @computed('numberChosen', 'directSelectAllotments')
  hasHitLimit(numberChosen, directSelectAllotments) {
    return numberChosen >= directSelectAllotments;
  },

  uniqSiteName: Ember.computed('model.user', function() {
    return this.get('model.user.positions').uniqBy('site_name').get('firstObject.site_name');
  }),

  totalAllotments: Ember.computed('model.user.positions', function() {
    return this.get('model.user.positions.firstObject.open_positions');
  }), 

  directSelectAllotments: math.floor(divide('totalAllotments', 'model.user.allocation_rule')),

  lotteryAllotments: math.ceil(divide('totalAllotments', 'model.user.allocation_rule')),

  selectionTotal: divide(100, 'model.user.allocation_rule'),


  @computed('model.user.positions')
  userInterests(positions) {
    return positions.mapBy('category').uniq().join(', ')
  },

  fakeSubmitButton: false,

  min: 0,
  max: 20,
  perPage: 20,

  @computed('max', 'perPage')
  page(max, perPage) {
    return Math.round(max/perPage);
  },

  @computed('model.applicants', 'model.user.positions')
  filteredApplicants(applicants, user_positions) {
    return applicants.filter(applicant=> {
      return user_positions.mapBy('category').some(category=>{
        return applicant.get('interests').includes(category);
      });
    })
  },

  @computed('model.applicants','min','max')
  paginatedModels(model,min,max) {
    return model.slice(min,max).sortBy('last_name');
  },

  @action
  previous() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('transition', 'toDown');
    this.set('min', min - perPage);
    this.set('max', max - perPage);
  },

  @action
  next() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('transition', 'toUp');
    this.set('min', min + perPage);
    this.set('max', max + perPage);
  },

  @action
  first() {
    let { min, max, perPage } = this.getProperties('min','max','perPage');
    this.set('transition', 'toDown');
    this.set('min', 0);
    this.set('max', perPage);
  },

  @action
  last() {
    let applicants = this.get('model.applicants');
    let perPage = this.get('perPage');
    let count = applicants.get('length');
    this.set('transition', 'toUp');
    this.set('min', Math.floor(count / perPage) * perPage );
    this.set('max', (Math.floor(count / perPage) * perPage) + perPage);
  },

  @action
  linkTo(model, event) {
    event.target.bringToFront();
    this.transitionToRoute('dashboard.partner.applicants', model);
  },


  @action
  linkToApplicant(applicant) {
    this.transitionToRoute('dashboard.partner.show-applicant', applicant.id);
  },


  @action
  setMapInstance(map) {
    this.set('mapState.mapInstance', map.target);
  },


  @action
  changePosition(pick, position) {
    pick.setProperties({ position });
    pick.save();
  },


  @action
  removePick(pick) {
    pick.deleteRecord();
    pick.save();
  },


  @action
  pickTeen(requisition) {
    let { applicant, position } = requisition.getProperties('applicant', 'position');
    requisition.set('status', 'hire');
    requisition.save();
    this.store.createRecord('pick', {
      applicant,
      position
    }).save();
  },


  @action
  hirePickedTeens() {
    let picks = this.get('model.picks');

    picks.invoke('set', 'status', 'hire');
    picks.invoke('save');
    this.set('fakeSubmitButton', true);
  }
});
