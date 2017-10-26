require "rails_helper"

RSpec.describe RequisitionsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(:get => "/api/requisitions/1").to route_to("requisitions#show", :id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/requisitions/1").to route_to("requisitions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/requisitions/1").to route_to("requisitions#update", :id => "1")
    end
  end
end
