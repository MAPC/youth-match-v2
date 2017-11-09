class Pick < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
  enum status: [:interested, :hire, :do_not_hire]
  after_save :create_offer, if: :hired?

  private

  def create_offer
    offer = Offer.create(applicant: applicant, position: position)
    JobOfferMailer.job_offer_email(offer.applicant.user).deliver_later
    if offer.applicant.receive_text_messages && offer.applicant.mobile_phone
      SendTextJob.perform_later(offer.applicant.mobile_phone, 'Congrats, you got a summer job offer! Please check your email. You must still upload documents to your City of Boston profile and complete work tasks.')
    end
  end

  def hired?
    status == 'hire'
  end
end
