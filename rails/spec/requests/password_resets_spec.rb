require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
  describe "POST /password_resets" do
    it "resets the user password and emails them" do
      admin_user = FactoryGirl.create(:staff_user)
      youth_user = FactoryGirl.create(:user)
      headers = { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{admin_user.authentication_token}, email=#{admin_user.email}" }
      post password_resets_path, params: %Q(
        {
          "data": {
            "type": "password_reset",
            "attributes": {
              "user_id": "#{youth_user.id}"
            }
          }
        }
      ), headers: headers
      expect(response).to have_http_status(200)
    end
  end

  it "fails if the user does not exist" do
    admin_user = FactoryGirl.create(:staff_user)
    youth_user = FactoryGirl.create(:user)
    headers = { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{admin_user.authentication_token}, email=#{admin_user.email}" }
    post password_resets_path, params: %Q(
      {
        "data": {
          "type": "password_reset",
          "attributes": {
            "user_id": "8675309"
          }
        }
      }
    ), headers: headers
    expect(response).to have_http_status(500)
  end

  it "fails if the requesting user is not staff" do
    admin_user = FactoryGirl.create(:user)
    youth_user = FactoryGirl.create(:user)
    headers = { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{admin_user.authentication_token}, email=#{admin_user.email}" }
    post password_resets_path, params: %Q(
      {
        "data": {
          "type": "password_reset",
          "attributes": {
            "user_id": "#{youth_user.id}"
          }
        }
      }
    ), headers: headers
    expect(response).to have_http_status(500)
  end
end
