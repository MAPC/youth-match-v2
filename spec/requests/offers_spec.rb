require 'rails_helper'

RSpec.describe "Offers", type: :request do
  describe "GET /offers" do
    it "works!" do
      user = FactoryGirl.create(:user)
      Offer.create
      get offers_path, headers: { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" }
      expect(response).to have_http_status(200)
    end
  end
end
