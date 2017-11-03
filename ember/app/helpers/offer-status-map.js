import Ember from 'ember';

export function offerStatusMap(params/*, hash*/) {
  const status = params[0] || 'no-status';
  
  const map = {
    'no-status': 'Offer Sent',
    'offer_sent': 'Offer Sent',
    'accept': 'Accepted',
    'decline': 'Declined',
    'withdraw': 'Withdrawn',
    'no_top_waitlist': 'Top of Waitlist',
    'no_bottom_waitlist': 'Bottom of Waitlist',
    'expired': 'Expired',
  };

  return map[status] || '';
}

export default Ember.Helper.helper(offerStatusMap);
