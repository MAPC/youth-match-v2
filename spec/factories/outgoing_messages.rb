FactoryGirl.define do
  factory :outgoing_message do
    to "8601231234"
    body "MyString"
  end
end
