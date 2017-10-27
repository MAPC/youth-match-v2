class OfferEmailsController < ApplicationController
  def create
    Offer.where(accepted: nil).each do |offer|
      JobOfferMailer.job_offer_email(offer.applicant.user).deliver_later
    end
    render body: 'Offer emails will be sent.'
  end
end
