class MatchApplicantsWithPositionsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    expire_waiting_applicants
    build_preference_lists
    match_applicants_to_positions
  end

  private

  def build_preference_lists
    Applicant.chosen(500).each do |applicant|
      Position.open.each do |position|
        next if Preference.where(applicant: applicant, position: position).present?
        score = travel_time_score(applicant, position) + interest_score(applicant, position)
        Preference.create(applicant: applicant, position: position, score: score)
      end
    end
  end

  def match_applicants_to_positions
    Applicant.chosen(500).each do |applicant|
      applicant.match_to_position
    end
    if Position.where(applicant: nil).any?
      match_applicants_to_positions
    end
  end

  def travel_time_score(applicant, position)
    minutes = travel_time(applicant, position) / 60
    applicant.prefers_nearby? ? care(minutes) : dont_care(minutes)
  end

  def travel_time(applicant, position)
    return TravelTime.find_by(
      input_id:     applicant.grid_id,
      target_id:    position.grid_id,
      travel_mode:  applicant.has_transit_pass ? "transit" : "walking"
    ).time
  rescue NoMethodError
    40.minutes.to_i
  end

  def care(minutes)
    minutes < 30 ? (0.008 * (minutes ** 2)) - (0.5833 * minutes) + 5 : -5
  end

  def dont_care(minutes)
    minutes < 40 ? (-0.25 * minutes) + 5 : -5
  end

  def interest_score(applicant, position)
    magnitude = applicant.prefers_interest? ? 5 : 3
    matches = (applicant.interests & [position.category]).any? ? 1 : -1
    return magnitude * matches
  end

  def expire_waiting_applicants
    Offers.where(accepted: 'waiting').update(accepted: 'no_bottom_waitlist')
  end
end
