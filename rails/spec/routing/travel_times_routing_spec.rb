require "rails_helper"

RSpec.describe TravelTimeScoresController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/travel_time_scores").to route_to("travel_time_scores#create")
    end
  end
end
