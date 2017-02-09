FactoryGirl.define do
  factory :applicant do
    first_name "MyString"
    last_name "MyString"
    email "MyString"
    icims_id 1
    interests "MyString"
    prefers_nearby false
    has_transit_pass false
    grid_id 1
    location ""
  end
end
