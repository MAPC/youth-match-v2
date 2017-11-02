class Applicant < ApplicationRecord
  has_many :preferences, dependent: :destroy
  has_many :requisitions, dependent: :destroy
  has_many :positions, through: :requisitions
  has_many :pickers, through: :picks, source: :position
  has_many :picks, dependent: :destroy
  has_many :offers
  belongs_to :user
 #  validate :positions_count_within_bounds
 validates :email, presence: true
 validates :icims_id, presence: true
 after_save :validate_email

  def match_to_position
    preferences.order(score: :desc).each do |preference|
      unless offers.where(accepted: nil).present?
        next if offers.pluck(:position_id).include?(preference.position_id)
        if preference.position.open? || preference.position.prefers?(self)
          if preference.position.open?
            Rails.logger.debug 'Giving applicant ' + self.id.to_s + ' open position: ' + preference.position.id.to_s
          else
            Rails.logger.debug 'Giving applicant ' + self.id.to_s + ' preferred position: ' + preference.position.id.to_s
          end
          Offer.new(applicant: self, position: preference.position).save!
          Rails.logger.debug "Offer Generated for #{first_name}"
        end
      end
    end
  end

  def self.chosen
    open_positions = Position.sum(:open_positions) - (Offer.where(accepted: 'yes').count + Offer.where(accepted: 'offer_sent').count + Offer.where(accepted: nil).count)
    # pull count of records of database equal to open positions that are in the lottery
    left_outer_joins(:offers).where(offers: { id: nil } ).order(:lottery_number).first(open_positions)
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest

  def mode
    has_transit_pass? ? 'pt' : 'foot'
  end

  private

  def positions_count_within_bounds
    return if positions.blank?
    errors.add(:positions, :size, message: 'You can only apply to ten or less positions') if positions.size > 10
  end

  def validate_email
    if valid_email.blank?
      ValidateEmailJob.perform_later(id)
    end
  end
end

# Applicant.position.prefers?
# Remaining issue: debug the position.prefers? method to figure out
# what it is actually preferring and how it is getting the applicant
