import Ember from 'ember';

export function pickStatusMap(params/*, hash*/) {
  const status = params[0] || 'no-status';
  
  const map = {
    'no-status': 'Picked',
    'hire': 'Offer Sent',
  };

  return map[status];
}

export default Ember.Helper.helper(pickStatusMap);
