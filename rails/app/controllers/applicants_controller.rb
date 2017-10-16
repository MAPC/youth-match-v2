class ApplicantsController < ApplicationController
  def index
    # todo: investigate why the nested routes aren't
    # returning only associated applicants. for now
    # this logic is necessary. see #51
    if params[:interests]
      @applicants = Applicant.where("interests && ARRAY[?]::varchar[]", params[:interests])
    else
      @applicants = Applicant.all
    end
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
    # ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:first_name, :last_name, :email, :icims_id, :interests, :prefers_nearby, :has_transit_pass, :grid_id, :location, :lottery_number, :receive_text_messages, :mobile_phone, :guardian_name, :guardian_phone, :guardian_email, :in_school, :school_type, :bps_student, :bps_school_name, :current_grade_level, :english_first_language, :first_language, :fluent_other_language, :other_languages, :held_successlink_job_before, :previous_job_site, :wants_to_return_to_previous_job, :superteen_participant, :participant_essay, :address, :home_phone, :workflow_id, :user_id, :neighborhood, :id])
  end
end
