class ApplicantsController < ApplicationController
  def index
    @applicants = Applicant.all
    respond_to do |format|
      format.jsonapi { render jsonapi: @applicants }
    end
  end

  def show
    @applicant = Applicant.find(params[:id])
    respond_to do |format|
      format.jsonapi { render jsonapi: @applicant }
    end
  end

  def update
    @applicant = Applicant.find(params[:id])
    if @applicant.update_attributes(applicant_params)
      respond_to do |format|
        format.jsonapi { render jsonapi: @applicant }
      end
    else
      head :forbidden
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit!
  end
end
