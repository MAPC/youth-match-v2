require 'rails_helper'

RSpec.describe "applicants/index", type: :view do
  before(:each) do
    user = FactoryGirl.create(:user)
    sign_in user
    assign(:applicants, [FactoryGirl.create(:applicant), FactoryGirl.create(:applicant)])
  end

  it "renders the applicant index form" do
    render
    expect(rendered).to match('Applicant')
    expect(rendered).to match('@')
  end
end
