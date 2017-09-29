class Preference < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
end
