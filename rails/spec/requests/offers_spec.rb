require 'rails_helper'

RSpec.describe "Offers", type: :request do
  describe "GET /offers" do
    it "works!" do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:offer, applicant: user.applicant)
      get offers_path, headers: { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" }
      expect(response).to have_http_status(200)
      expect(response_body['data'].count).to eq(1)
    end
  end

  describe "GET /offers?for_applicant=true" do
    it "returns only applicants for the current user" do
      user = FactoryGirl.create(:user_with_applicant)
      FactoryGirl.create(:offer, applicant: user.applicant)
      FactoryGirl.create(:offer)
      get offers_path, params: { for_applicant: true }, headers: { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" }
      expect(response).to have_http_status(200)
      expect(response_body['data'].count).to eq(1)
    end
  end

  def response_body
    JSON.parse(response.body)
  end
end
