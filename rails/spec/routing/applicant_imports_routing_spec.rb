require "rails_helper"

RSpec.describe ApplicantImportsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/applicant_imports").to route_to("applicant_imports#create")
    end
  end
end
