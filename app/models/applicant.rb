class Applicant < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences
  has_one :position
  has_one :offer

  def match_to_position
    preferences.order(score: :desc).each do |preference|
      unless self.offer.where(accepted: 'waiting').present?
        if preference.position.open? || preference.position.prefers?(self)
          # if preference.position.open?
          #   puts 'Giving applicant ' + self.id.to_s + ' open position: ' + preference.position.id.to_s
          # else
          #   puts 'Giving applicant ' + self.id.to_s + ' preferred position: ' + preference.position.id.to_s
          # end
          Offer.where(position: preference.position).destroy_all # <--this will destroy the old offers, not good!
          Offer.new(applicant: self, position: preference.position, accepted: 'waiting').save!
        end
      end
    end
  end

  def self.chosen(count)
    # 1. Take the folks from the top of the wait list
    chosen_applicants = top_waitlist(count)
    count - chosen_applicants.count
    return chosen_applicants if count == 0
    # 2. Then add in the next lottery iteration.
    chosen_applicants += not_yet_offered(count)
    count - not_yet_offered(count).count
    return chosen_applicants if count == 0
    # 3. Then fill with people at the bottom of the waitlist
    chosen_applicants += bottom_waitlist(count)
    # New problem: what do we do for folks who had an offer before? Now they need a new offer.
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

  def top_waitlist(count)
    joins(:offer).where(offers: { accepted: 'no_top_waitlist' } ).order(:lottery_number).limit(count)
  end

  def not_yet_offered(count)
    where.not(id: Offer.select(:applicant_id)).order(:lottery_number).limit(count)
  end

  def bottom_waitlist(count)
    joins(:offer).where(offers: { accepted: 'no_bottom_waitlist' } ).order(:lottery_number).limit(count)
  end
end
