require 'rails_helper'

RSpec.describe ApplicantsController, type: :controller do
  let(:applicant) { FactoryGirl.create(:applicant) }
  let(:position) { FactoryGirl.create(:position) }
  let(:valid_session) { {} }

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { "position_ids" => [position.id] }
      }

      it "updates the requested applicant" do
        request.headers['Content-Type'] = 'application/vnd.api+json'
        request.headers['Accept'] = 'application/vnd.api+json'
        put :update, params: { id: applicant.to_param, applicant: new_attributes }
        applicant.reload
        expect(applicant.positions.count).to eq(1)
      end
    end
  end
end
