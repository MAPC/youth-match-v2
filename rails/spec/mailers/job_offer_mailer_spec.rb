require "rails_helper"

RSpec.describe JobOfferMailer, type: :mailer do
  it 'updates the offer that is emailed to offer_sent status' do
    user = FactoryGirl.create(:user_with_applicant)
    position = FactoryGirl.create(:position)
    offer = FactoryGirl.create(:offer, applicant: user.applicant, position: position)
    JobOfferMailer.job_offer_email(user).deliver_now
    offer.reload
    expect(offer.accepted).to eq('offer_sent')
  end
end
