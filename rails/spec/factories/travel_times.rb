FactoryGirl.define do
  factory :travel_time do
    input_id 1
    target_id 1
    g250m_id_origin 1
    g250m_id_destination 1
    distance ""
    x_origin "9.99"
    y_origin "9.99"
    x_destination "9.99"
    y_destination "9.99"
    travel_mode "MyString"
    time 1
    pair_id 1
  end
end
