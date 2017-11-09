import Ember from 'ember';
import { computed } from 'ember-decorators/object';


export default Ember.Controller.extend({

  steps: {
    '1': {
      title: 'Submit Job Application',
      message: "Thank you, we've received your application!",
    },

    '2': {
      title: 'Find the Right Job',
      message: "You've shown interest in $num job$ess.",
    },

    '3': {
      title: 'Receive a Job Offer',
      message: 'Congrats, you have a job offer!',
    },

    '4': {
      title: 'Accept or Decline Your Offer',
      message: "Thank you! You've accepted or declined your job.",
    },

    '5': {
      title: 'Complete Onboarding',
      message: 'You are now in onboarding. Go <a href="">here</a> to complete more steps.',
    },
  },

  animationTriggered: false,


  @computed('model.applicant.offers')
  applicantOffer(offers) {
    return offers.get('firstObject');
  },

  @computed('model.applicant', 'model.applicant.positions', 'applicantOffer')
  step(applicant, positions, offer) {

    /*
     * Step 5 should occur after the data has been exported to ICIMs.
     */
    /*
    if () {
      return '5';
    }
    */

    if (offer) {
      const status = ('' + offer.get('accepted')).toLowerCase();

      if (status === 'yes' || status === 'no_bottom_waitlist') {
        return '4';
      }
      else if (status !== 'expire') {
        return '3';
      }
    }
    if (positions.get('length')) {
      return '2'; 
    }

    return '1';   
  },

  @computed('model.applicant')
  applicantEmail(applicant) {
    const emailPieces =  applicant.get('email').split('@');
    emailPieces[0] = emailPieces[0].split('').map(() => '*').join('');

    return emailPieces.join('@');
  },


  @computed('step', 'steps', 'model.applicant.positions.length')
  stepMessage(step, steps, positionsLength) {
    let message = steps[step].message;

    if (step === '2') {
      message = message.replace('$num', positionsLength)
                       .replace('$ess', positionsLength === 1 ? '' : 's');
    }
    
    return message;
  },


  @computed('step', 'animationTriggered', 'triggerAnimation')
  stepClass(step, triggered) {
    if (triggered) {
      return `step-${step}`;
    }
  },


  // :face_with_rolling_eyes:
  @computed
  triggerAnimation() {
    setTimeout(() => { this.set('animationTriggered', true); }, 500);
  },

});
