require 'faker'

FactoryGirl.define do
  factory :position do
    sequence(:icims_id) { |n| n }
    sequence(:title) { |n| "Title #{n}" }
    sequence(:category) { |n| "Category #{n}" }
    location ''
    duties_responsbilities 'Some duties and responsibilites.'
    ideal_candidate 'The ideal candidate.'
    open_positions { Faker::Number.between(1, 2) }
    site_name { Faker::Company.unique.name }
    external_application_url 'http://www.nytimes.com'
    primary_contact_person { Faker::Name.unique.name }
    primary_contact_person_title { Faker::Name.unique.title }
    primary_contact_person_phone { Faker::PhoneNumber.phone_number }
    site_phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.street_address }
    primary_contact_person_email { Faker::Internet.unique.email }

    trait :with_applicant do
      after_create do |position|
        create(:applicant, position: position)
      end
    end
  end
end
