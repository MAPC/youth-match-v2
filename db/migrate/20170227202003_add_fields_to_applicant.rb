class AddFieldsToApplicant < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :in_school, :string
    add_column :applicants, :school_type, :string
    add_column :applicants, :bps_student, :boolean
    add_column :applicants, :bps_school_name, :string
    add_column :applicants, :current_grade_level, :string
    add_column :applicants, :english_first_language, :boolean
    add_column :applicants, :first_language, :string, array: true
    add_column :applicants, :fluent_other_language, :boolean
    add_column :applicants, :other_languages, :string, array: true
    add_column :applicants, :held_successlink_job_before, :boolean
    add_column :applicants, :previous_job_site, :string
    add_column :applicants, :wants_to_return_to_previous_job, :boolean
    add_column :applicants, :superteen_participant, :boolean
    add_column :applicants, :participant_essay, :text
  end
end
