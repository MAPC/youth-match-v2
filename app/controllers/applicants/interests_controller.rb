class Applicants::InterestsController < ApplicationController
  def index
    @applicants = Applicant.where("interests && ARRAY[?]::varchar[]", params[:interests])
    respond_to do |format|
      format.jsonapi { render jsonapi: @applicants }
    end
  end
end
