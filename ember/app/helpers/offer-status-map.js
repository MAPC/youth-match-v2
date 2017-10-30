import Ember from 'ember';

export function offerStatusMap(params/*, hash*/) {
  const status = params[0] || 'no-status';
  
  const map = {
    'no-status': 'Offer Sent',
    'accept': 'Accepted',
    'decline': 'Declined',
  };

  return map[status];
}

export default Ember.Helper.helper(offerStatusMap);
