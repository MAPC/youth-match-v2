require 'faker'

FactoryGirl.define do
  factory :applicant do
    first_name { Faker::Name.unique.first_name }
    last_name { Faker::Name.unique.last_name }
    email { Faker::Internet.unique.email }
    sequence(:icims_id) { |n| n }
    interests ['Interest1', 'Interest2', 'Interest3', 'Interest4', 'Interest5']
    prefers_nearby { Faker::Boolean.boolean }
    has_transit_pass { Faker::Boolean.boolean }
    receive_text_messages { Faker::Boolean.boolean }
    mobile_phone { Faker::PhoneNumber.phone_number }
    guardian_name { Faker::Name.name }
    guardian_phone { Faker::PhoneNumber.phone_number }
    guardian_email { Faker::Internet.email }
    in_school { Faker::Boolean.boolean }
    school_type 'Public School'
    bps_student { Faker::Boolean.boolean }
    current_grade_level '11th'
    english_first_language { Faker::Boolean.boolean }
    first_language 'English'
    fluent_other_language { Faker::Boolean.boolean }
    held_successlink_job_before { Faker::Boolean.boolean }
    superteen_participant { Faker::Boolean.boolean }
    participant_essay 'Pick me!'
    home_phone { Faker::PhoneNumber.phone_number }
    workflow_id { |n| n }
    sequence(:grid_id) { |n| n }
    location ''
  end
end
