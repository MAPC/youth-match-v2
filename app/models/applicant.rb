class Applicant < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences
  has_one :position
  has_one :offer

  def match_to_position
    preferences.order(score: :desc).each do |preference|
      unless self.offer.present?
        if preference.position.open? || preference.position.prefers?(self)
          # if preference.position.open?
          #   puts 'Giving applicant ' + self.id.to_s + ' open position: ' + preference.position.id.to_s
          # else
          #   puts 'Giving applicant ' + self.id.to_s + ' preferred position: ' + preference.position.id.to_s
          # end
          Offer.where(position: preference.position).destroy_all
          Offer.new(applicant: self, position: preference.position).save!
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
