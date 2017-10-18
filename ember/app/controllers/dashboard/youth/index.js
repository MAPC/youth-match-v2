import Ember from 'ember';
import { computed } from 'ember-decorators/object';


export default Ember.Controller.extend({

  steps: {
    '1': {
      title: 'Submit Job Application',
      message: "Welcome to SuccessLink!",
    },

    '2': {
      title: 'Find the Right Job',
      message: "You've shown interest in 10 available jobs.",
    },

    '3': {
      title: 'Receive a Job Offer',
      message: 'Congrats, you have a job offer!',
    },

    '4': {
      title: 'Accept or Decline Your Offer',
      message: "You've accepted your job.",
    },

    '5': {
      title: 'Complete Onboarding',
      message: 'Congrats, you have completed your journey!',
    },
  },


  @computed('model.applicant', 'model.applicant.positions')
  step(applicant, positions) {
    if (applicant.hasReachedMaxPositions) {
      return 2; 
    }

    return 1;   
  },


  @computed('step', 'steps')
  stepMessage(step, steps) {
    return steps[step].message;
  },
  

});
