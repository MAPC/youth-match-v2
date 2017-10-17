require 'rails_helper'

RSpec.describe "positions", type: :request do
  describe "PUT /api/positions" do
    it "associates a position with an applicant when the applicant expresses interest in the job" do
      user = FactoryGirl.create(:user_with_position)
      applicant = FactoryGirl.create(:applicant)
      position = user.positions.first
      headers = { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" }
      # For unknown reasons a raw body needs to be passed as params keyword argument. See: https://stackoverflow.com/a/44752082
      patch "/api/positions/#{position.id}", params: %Q({"data":{"id":"#{position.id}","attributes":{"category":"#{position.category}","site_name":null,"title":"#{position.title}","external_application_url":null,"primary_contact_person":null,"primary_contact_person_title":null,"primary_contact_person_email":null,"address":null,"primary_contact_person_phone":null,"site_phone":null,"duties_responsbilities":null,"ideal_candidate":null,"neighborhood":null,"open_positions":null},"relationships":{"applicants":{"data":[{"type":"applicants","id":"#{applicant.id}"}]}},"type":"positions"}}), headers: headers
      expect(JSON.parse(response.body)['data']['relationships']['applicants']['data'].count).to eq 1
    end

    it "destroys the association between the position and applicant when the applicant is no longer interested" do
      user = FactoryGirl.create(:user_with_position)
      position = user.positions.first
      applicant = FactoryGirl.create(:applicant, positions: [position])
      headers = { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" }
      patch "/api/positions/#{position.id}", params: %Q({"data":{"id":"#{position.id}","attributes":{"category":"#{position.category}","site_name":null,"title":"#{position.title}","external_application_url":null,"primary_contact_person":null,"primary_contact_person_title":null,"primary_contact_person_email":null,"address":null,"primary_contact_person_phone":null,"site_phone":null,"duties_responsbilities":null,"ideal_candidate":null,"neighborhood":null,"open_positions":null},"relationships":{"applicants":{"data":[]}},"type":"positions"}}), headers: headers
      expect(JSON.parse(response.body)['data']['relationships']['applicants']['data'].count).to eq 0
    end
  end
end
