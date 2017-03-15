class ApplicantSerializer < ActiveModel::Serializer
  attributes  :first_name, :last_name, :email, :icims_id, :interests, :prefers_nearby, 
              :has_transit_pass, :grid_id, :latitude, :longitude, :lottery_number, :receive_text_messages, 
              :mobile_phone, :guardian_name, :guardian_phone, :guardian_email, :in_school, :school_type, 
              :bps_student, :bps_school_name, :current_grade_level, :english_first_language, :first_language, 
              :fluent_other_language, :other_languages, :held_successlink_job_before, :previous_job_site, 
              :wants_to_return_to_previous_job, :superteen_participant, :participant_essay, :address, 
              :participant_essay_attached_file, :home_phone, :workflow_id

  def latitude
    object.location.y
  end

  def longitude
    object.location.x
  end
end
