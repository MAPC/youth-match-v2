require 'rails_helper'

RSpec.describe "OutgoingMessages", type: :request do
  describe "GET /outgoing_messages" do
    it "works!" do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:outgoing_message)
      get outgoing_messages_path, headers: { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" }
      expect(response).to have_http_status(200)
    end
  end
end
