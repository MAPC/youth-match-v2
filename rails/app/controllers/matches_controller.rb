class MatchesController < ApplicationController
  def create
    MatchApplicantsWithPositionsJob.perform_later
  end
end
