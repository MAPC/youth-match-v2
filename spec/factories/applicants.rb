FactoryGirl.define do
  factory :applicant do
    sequence(:first_name) { |n| "FirstName#{n}" }
    sequence(:last_name) { |n| "LastName#{n}" }
    sequence(:email) { |n| "example_email#{n}@example.com" }
    sequence(:icims_id) { |n| n }
    interests "MyString"
    prefers_nearby false
    has_transit_pass false
    sequence(:grid_id) { |n| n }
    location ""
  end
end
