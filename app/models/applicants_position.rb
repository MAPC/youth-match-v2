class ApplicantsPosition < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
  enum status: [:applicant_interested, :currently_interviewing, :intend_to_hire]
end
