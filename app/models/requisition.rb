class Requisition < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
  enum status: [:interested, :hire, :do_not_hire]
end
