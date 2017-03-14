class ApplicantsController < ApplicationController
  def index
    @applicants = Applicant.all
    respond_to do |format|
      format.jsonapi { render jsonapi: @applicants }
    end
  end
end
