require "rails_helper"

RSpec.describe LotteryActivatedStatusesController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/api/lottery_activated_statuses").to route_to("lottery_activated_statuses#create")
    end
  end
end
