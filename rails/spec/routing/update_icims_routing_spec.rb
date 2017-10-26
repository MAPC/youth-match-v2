require "rails_helper"

RSpec.describe UpdateIcimsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/update_icims").to route_to("update_icims#create")
    end
  end
end
