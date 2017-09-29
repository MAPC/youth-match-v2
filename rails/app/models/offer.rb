class Offer < ApplicationRecord
  enum accepted: [:waiting, :yes, :withdraw, :no_top_waitlist, :no_bottom_waitlist, :expired]
  belongs_to :applicant
  belongs_to :position
end
