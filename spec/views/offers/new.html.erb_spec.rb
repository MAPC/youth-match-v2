require 'rails_helper'

RSpec.describe "offers/new", type: :view do
  before(:each) do
    assign(:offer, Offer.new(
      :applicant => create(:applicant),
      :position => create(:position),
      :accepted => 1
    ))
  end

  it "renders new offer form" do
    render

    assert_select "form[action=?][method=?]", offers_path, "post" do

      assert_select "input#offer_applicant[name=?]", "offer[applicant]"

      assert_select "input#offer_position[name=?]", "offer[position]"

      assert_select "input#offer_accepted[name=?]", "offer[accepted]"
    end
  end
end
