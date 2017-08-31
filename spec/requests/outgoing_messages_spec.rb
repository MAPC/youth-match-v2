require 'rails_helper'

RSpec.describe "OutgoingMessages", type: :request do
  describe "GET /outgoing_messages" do
    it "works! (now write some real specs)" do
      user = FactoryGirl.create(:user)
      sign_in user
      get outgoing_messages_path
      expect(response).to have_http_status(200)
    end
  end
end
