FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'

    trait :with_applicant do
      applicant
    end
    factory :user_with_applicant, traits: [:with_applicant]
  end
end
