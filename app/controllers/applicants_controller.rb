class ApplicantsController < ApplicationController
  def index
    # todo: investigate why the nested routes aren't
    # returning only associated applicants. for now
    # this logic is necessary. see #51
    if params
      @applicants = Applicant.includes(:positions).where('positions.id' => params[:position_id])
    else
      @applicants = Applicant.all
    end
    respond_to do |format|
      format.jsonapi { render jsonapi: @applicants }
    end
  end

  def first_timers
    @applicants = Applicant.first_timers
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
