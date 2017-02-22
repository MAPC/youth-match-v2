class Applicant < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences
  has_one :position

  def match_to_position
    preferences.order(score: :desc).each do |preference|
      unless self.position.present?
        if preference.position.open? || preference.position.prefers?(self)
          update(position: preference.position)
        end
      end
    end
  end

  def self.chosen(first = 1)
    where(lottery_number: first..Position.count).order(:lottery_number)
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest

  private

  def compute_grid_id
    grid = Box.intersects(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end

# Applicant.position.prefers?
# Remaining issue: debug the position.prefers? method to figure out
# what it is actually preferring and how it is getting the applicant

