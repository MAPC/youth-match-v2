class Requisition < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
  enum partner_status: [:interested, :not_interested]
  enum applicant_status: [:submitted, :withdrawn]
end
