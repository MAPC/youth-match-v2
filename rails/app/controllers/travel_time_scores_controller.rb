class TravelTimeScoresController < ApplicationController
  def create
    Preference.delete_all
    Applicant.all.each do |applicant|
      Position.all.each do |position|
        BuildTravelTimePreferenceJob.perform_later(applicant.id, position.id)
      end
    end
  end
end
