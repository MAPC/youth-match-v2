class MatchRunsController < ApplicationController
  # A match run probably has many offers. That way we can show what offers are associated with the match run.

  def index
  end

  def show
  end

  def create
    MatchApplicantsWithPositionsJob.perform_later
    render body: 'Applicants will be matched with positions.'
  end
end
