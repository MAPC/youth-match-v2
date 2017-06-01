class Applicant < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences, dependent: :destroy
  has_many :requisitions, dependent: :destroy
  has_many :positions, through: :requisitions
  has_many :pickers, through: :picks, source: :position
  has_many :picks, dependent: :destroy
  has_many :offers
  belongs_to :user
 #  validate :positions_count_within_bounds
  scope :first_timers, -> { joins("LEFT JOIN rehire_sites ON applicants.icims_id = rehire_sites.icims_id WHERE rehire_sites.icims_id IS NULL") }
  scope :with_rehire_sites, -> { select('*').joins("LEFT OUTER JOIN rehire_sites ON rehire_sites.icims_id = applicants.icims_id") }

  def match_to_position
    preferences.order(score: :desc).each do |preference|
      unless self.offers.where(accepted: 'waiting').present?
        next if offers.pluck(:position_id).include?(preference.position_id)
        if preference.position.open? || preference.position.prefers?(self)
          # if preference.position.open?
          #   puts 'Giving applicant ' + self.id.to_s + ' open position: ' + preference.position.id.to_s
          # else
          #   puts 'Giving applicant ' + self.id.to_s + ' preferred position: ' + preference.position.id.to_s
          # end
          Offer.new(applicant: self, position: preference.position, accepted: 'waiting').save!
          puts "Offer Generated for #{first_name}"
        end
      end
    end
  end

  def self.chosen
    open_positions = Position.sum(:open_positions)
    # pull count of records of database equal to open positions that are in the lottery
    where(lottery_activated: true).order(:lottery_number).first(open_positions)
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest

  def mode
    has_transit_pass? ? 'transit' : 'walking'
  end

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
