import Ember from 'ember';

export function offerStatusMap(params/*, hash*/) {
  const status = params[0] || 'no-status';
  
  const map = {
    'no-status': 'Offer Sent',
    'offer_sent': 'Offer Sent',
    'yes': 'Accepted',
    'no_bottom_waitlist': 'Declined',
    'withdraw': 'Withdrawn',
    'no_top_waitlist': 'Top of Waitlist',
    'expired': 'Expired',
  };

  return map[status] || '';
}

export default Ember.Helper.helper(offerStatusMap);
