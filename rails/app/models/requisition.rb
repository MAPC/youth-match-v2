class Requisition < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
  enum status: [:interested, :do_not_hire]
end
