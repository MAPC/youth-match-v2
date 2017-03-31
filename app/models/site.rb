class Site < ApplicationRecord
  belongs_to :position
  belongs_to :user
end
