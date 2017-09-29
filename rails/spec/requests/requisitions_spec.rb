require 'rails_helper'

RSpec.describe "Requisitions", type: :request do
  describe "PATCH /offers" do
    it "works!" do
      pending 'Test does not work with authorization due to https://github.com/rspec/rspec-rails/issues/1655'
      position = FactoryGirl.create(:position)
      applicant = FactoryGirl.create(:applicant)
      requisition = Requisition.create(applicant: applicant, position: position, status: 'applicant_interested')
      user = FactoryGirl.create(:user) # user must be associated with the position to work
      put requisition_path(requisition), { id: requisition.id, requisition: { status: 'currently_interviewing' } }
      expect(response).to redirect_to(requisition)
    end
  end
end
