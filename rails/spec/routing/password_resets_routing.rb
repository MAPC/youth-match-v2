require "rails_helper"

RSpec.describe PasswordResetsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/password_resets").to route_to("password_resets#create")
    end
  end
end
