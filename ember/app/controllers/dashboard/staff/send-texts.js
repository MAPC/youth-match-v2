import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';


export default Ember.Controller.extend({

  messageBody: '',
  textLength: 160,

  sending: false,

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
    return (textCount * textLength) || textLength;
  },


  @action
  loadPremadeMessage(messageType) {
    this.set('messageBody', this.get('premadeMessages')[messageType]);
  },


  @action
  sendText() {
    const body = this.get('messageBody');

    if (body.length > 0 && !this.get('sending')) {
      this.set('sending', true);

      this.store.createRecord('outgoingMessage', { body })
      .save()
      .finally(() => {
        this.set('messageBody', '');
        this.set('sending', false);
      });
    }
  },

});
