require 'rails_helper'

RSpec.describe "OfferEmails", type: :request do
  describe 'POST /offer_emails' do
    it 'works!' do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:offer)
      post offer_emails_path, headers: { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" }
      expect(response).to have_http_status(200)
    end
  end
end
