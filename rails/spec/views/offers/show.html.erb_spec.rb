require 'rails_helper'

RSpec.describe "offers/show", type: :view do
  before(:each) do
    @offer = assign(:offer, Offer.create!(
      :applicant => create(:applicant),
      :position => create(:position),
      :accepted => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match('Applicant')
    expect(rendered).to match('Position')
  end
end
