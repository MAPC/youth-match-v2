require 'rails_helper'

RSpec.describe "offers/index", type: :view do
  before(:each) do
    assign(:offers, [
      Offer.create!(
        :applicant => create(:applicant),
        :position => create(:position),
        :accepted => 1
      ),
      Offer.create!(
        :applicant => create(:applicant),
        :position => create(:position),
        :accepted => 1
      )
    ])
  end

  it "renders a list of offers" do
    render
    expect(rendered).to match('Applicant')
    expect(rendered).to match('Position')
  end
end
