class BuildPreferenceListsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.all.each do |applicant|
      applicant.preferences.order(travel_time_score: :asc).each_with_index do |preference, index|
        preference.score = normalize_travel_time_score(preference.applicant, index) + interest_score(preference.applicant, preference.position)
        preference.save
      end
    end
  end

  private

  def normalize_travel_time_score(applicant, rank)
    interval = applicant.preferences.count / 10.0 # factor to divide the travel_time_score rank by
    new_score = rank / interval # here we are placing the rank on the new scale of 0-10
    new_score - 5 # and then subtract 5 to move to same scale of -5 to 5
  end

  def interest_score(applicant, position)
    magnitude = applicant.prefers_interest? ? 5 : 3
    matches = (applicant.interests & [position.category]).any? ? 1 : -1
    magnitude * matches
  end
end
