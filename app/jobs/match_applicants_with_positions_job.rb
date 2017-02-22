class MatchApplicantsWithPositionsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    match_applicants_to_positions
  end

  private

  def match_applicants_to_positions
    Applicant.chosen.each do |applicant|
      applicant.match_to_position
    end
    if Position.where(applicant: nil).any?
      match_applicants_to_positions
    end
  end
end
