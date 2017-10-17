FactoryGirl.define do
  factory :position do
    sequence(:icims_id) { |n| n }
    sequence(:title) { |n| "Title #{n}" }
    sequence(:category) { |n| "Category #{n}" }
    location ''

    trait :with_applicant do
      after_create do |position|
        create(:applicant, position: position)
      end
    end
  end
end
