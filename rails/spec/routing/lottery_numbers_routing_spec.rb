require "rails_helper"

RSpec.describe LotteryNumbersController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/lottery_numbers").to route_to("lottery_numbers#create")
    end
  end
end
