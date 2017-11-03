import Ember from 'ember';

export function pickStatusMap(params/*, hash*/) {
  const status = params[0] || 'no-status';
  
  const map = {
    'no-status': 'Picked',
    'hire': 'Offer Sent',
    'interested': 'Interested',
    'do_not_hire': 'Do Not Hire',
  };

  return map[status] || '';
}

export default Ember.Helper.helper(pickStatusMap);
