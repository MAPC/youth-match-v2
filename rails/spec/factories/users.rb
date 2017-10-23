FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'

    trait :with_applicant do
      applicant
    end

    trait :staff do
      account_type 'staff'
    end

    trait :with_position do
      after(:create) do |user|
        create(:position, users: [user])
      end
    end
    factory :user_with_applicant, traits: [:with_applicant]
    factory :user_with_position, traits: [:with_position]
    factory :staff_user, traits: [:staff]
  end
end
