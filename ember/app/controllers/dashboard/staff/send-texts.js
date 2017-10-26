import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';
import config from '../../../config/environment';
import url from 'npm:url';


export default Ember.Controller.extend({

  ajax: Ember.inject.service(),
  messageBody: '',

  textLength: 160,

  premadeMessages: {
    offer: "",
    reminder: "",
    thanks: "",
    next: "",
  },


  @computed('textLength', 'messageBody') 
  textCount(textLength, messageBody) {
    return Math.ceil(messageBody.length / textLength);
  },


  @computed('textCount', 'textLength')
  characterThreshold(textCount, textLength) {
    return textCount * textLength;
  },


  @action
  loadPremadeMessage(messageType) {
    this.set('messageBody', this.get('premadeMessages')[messageType]);
  },


  @action
  sendText() {
    const body = this.get('messageBody');
    console.log(this.store.createRecord('outgoingMessage', { body }));
    return;

    this.store.createRecord('outgoingMessage', { body }).save();

  },

});
