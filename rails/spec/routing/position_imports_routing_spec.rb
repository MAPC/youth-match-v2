require "rails_helper"

RSpec.describe PositionImportsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/position_imports").to route_to("position_imports#create")
    end
  end
end
