require 'rails_helper'

RSpec.describe "offers/edit", type: :view do
  before(:each) do
    @offer = assign(:offer, Offer.create!(
      :applicant => create(:applicant),
      :position => create(:position),
      :accepted => 1
    ))
  end

  it "renders the edit offer form" do
    render

    assert_select "form[action=?][method=?]", offer_path(@offer), "post" do

      assert_select "input#offer_applicant[name=?]", "offer[applicant]"

      assert_select "input#offer_position[name=?]", "offer[position]"

      assert_select "input#offer_accepted[name=?]", "offer[accepted]"
    end
  end
end
