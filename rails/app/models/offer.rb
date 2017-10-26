class Offer < ApplicationRecord
  enum accepted: [:waiting, :yes, :withdraw, :no_top_waitlist, :no_bottom_waitlist, :expired]
  belongs_to :applicant
  belongs_to :position
  after_save :email_decliner, if: :declined?

  private

  def declined?
    case accepted
    when 'withdraw', 'no_bottom_waitlist', 'no_top_waitlist'
      true
    else
      false
    end
  end

  def email_decliner
    user = applicant.user
    ApplicantMailer.decline_offer_email(user).deliver_later
  end
end
