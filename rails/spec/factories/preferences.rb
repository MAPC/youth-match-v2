require 'faker'
FactoryGirl.define do
  factory :preference do
    applicant
    position
    travel_time_score { Faker::Number.between(-5, 5) }
    score { Faker::Number.between(-10, 10) }
  end
end
