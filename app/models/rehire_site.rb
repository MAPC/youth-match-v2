class RehireSite < ApplicationRecord
  scope :with_applicant_data, -> { joins("LEFT OUTER JOIN applicants ON applicants.icims_id = rehire_sites.icims_id") }
end
