class Pick < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
  enum status: [:interested, :hire, :do_not_hire]
  after_save :create_offer, if: :hired?

  private

  def create_offer
    Offer.create(applicant: applicant, position: position)
  end

  def hired?
    status == 'hire'
  end
end
