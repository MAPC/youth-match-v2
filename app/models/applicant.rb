class Applicant < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences
  has_many :applicants_position
  has_many :positions, through: :applicants_position
  has_one :offer
  belongs_to :user
  validate :positions_count_within_bounds

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

  def positions_count_within_bounds
    return if positions.blank?
    errors.add(:positions, :size, message: 'You can only apply to ten or less positions') if positions.size > 10
  end
end

# Applicant.position.prefers?
# Remaining issue: debug the position.prefers? method to figure out
# what it is actually preferring and how it is getting the applicant
