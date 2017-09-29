FactoryGirl.define do
  factory :applicant do
    sequence(:first_name) { |n| "FirstName#{n}" }
    sequence(:last_name) { |n| "LastName#{n}" }
    sequence(:email) { |n| "example_email#{n}@example.com" }
    sequence(:icims_id) { |n| n }
    interests ['Interest1', 'Interest2', 'Interest3', 'Interest4', 'Interest5']
    prefers_nearby false
    has_transit_pass false
    receive_text_messages true
    mobile_phone 1231231234
    guardian_name 'Guardian'
    guardian_phone '1231231234'
    guardian_email { |n| "example_email#{n}@example.com" }
    in_school true
    school_type 'Public School'
    bps_student true
    current_grade_level '11th'
    english_first_language true
    first_language 'English'
    fluent_other_language false
    held_successlink_job_before false
    superteen_participant false
    participant_essay 'Pick me!'
    home_phone '1231231234'
    workflow_id { |n| n }
    sequence(:grid_id) { |n| n }
    location ''
  end
end
