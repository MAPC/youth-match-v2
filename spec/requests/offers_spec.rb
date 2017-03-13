require 'rails_helper'

RSpec.describe "Offers", type: :request do
  describe "GET /offers" do
    it "works!" do
      Offer.create
      get offers_path, headers: { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' }
      expect(response).to have_http_status(200)
    end
  end
end
