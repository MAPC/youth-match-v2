class OfferEmailsController < ApplicationController
  def create
    Offer.where(accepted: nil).each do |offer|
      JobOfferMailer.job_offer_email(offer.applicant.user).deliver_later
      if offer.applicant.receive_text_messages && offer.applicant.mobile_phone
        SendTextJob.perform_later(offer.applicant.mobile_phone, 'Congrats, you got a summer job offer! Please check your email. You must still upload documents to your City of Boston profile and complete work tasks.')
      end
    end
    head :created
  end
end
