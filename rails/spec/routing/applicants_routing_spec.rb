require "rails_helper"

RSpec.describe ApplicantsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/applicants").to route_to("applicants#index")
    end

    it "routes to #show" do
      expect(:get => "/api/applicants/1").to route_to("applicants#show", :id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/applicants/1").to route_to("applicants#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/applicants/1").to route_to("applicants#update", :id => "1")
    end
  end
end
