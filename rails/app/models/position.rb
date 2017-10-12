class Position < ApplicationRecord
  has_many :preferences
  has_many :requisitions
  has_many :applicants, through: :requisitions
  has_many :selections, through: :picks, source: :applicant
  has_many :picks
  has_many :users, through: :sites
  has_many :sites
  has_many :offers

  def open?
    lottery_slots = open_positions
    lottery_slots -= offers.where(accepted: 'waiting').count
    return true if lottery_slots > 0
    return false
  end

  def prefers?(new_applicant)
    # return true if the new_applicant has a higher score relative to this position than if the
    # current applicant assigned to the position.
    puts 'Checking preference for offer from new applicant'
    lowest_score_offer = nil
    lowest_score_offer_score = 10
    offers.where(accepted: 'waiting').each do |offer| # get the current list of accepted: "waiting" offers associated with the position
      score = Preference.find_by(applicant: offer.applicant, position: offer.position).score
      if score < lowest_score_offer_score
        lowest_score_offer = offer
        lowest_score_offer_score = score
      end
    end

    if preferences.find_by(applicant: new_applicant).score > lowest_score_offer_score
      puts "Destroying lowest scored offer for position #{title}"
      lowest_score_offer.destroy
      return true
    end
    return false
    # preferences.find_by(applicant: new_applicant).score >
    # preferences.find_by(applicant: self.offer.applicant).score
  end
end
