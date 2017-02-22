class BuildPreferenceListsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.chosen(1).each do |applicant|
      Position.each do |position|
        score = travel_time_score(applicant, position) + interest_score(applicant, position)
        Preference.create(applicant: applicant, position: position, score: score)
      end
    end
  end

  private

  def travel_time_score(applicant, position)
    minutes = travel_time(applicant, position).to_i / 60
    applicant.prefers_nearby? ? care(minutes) : dont_care(minutes)
  end

  def travel_time(applicant, position)
    TravelTime.find_by(
      input_id:     applicant.grid_id,
      target_id:    position.grid_id,
      travel_mode:  applicant.mode
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
    matches = (applicant.interests & position.category).any? ? 1 : -1
    return magnitude * matches
  end
end
