FactoryGirl.define do
  factory :position do
    sequence(:icims_id) { |n| n }
    sequence(:title) { |n| "Title #{n}" }
    sequence(:category) { |n| "Category #{n}" }
    location ''
  end
end
