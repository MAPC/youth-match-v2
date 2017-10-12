require "rails_helper"

RSpec.describe OutgoingMessagesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/outgoing_messages").to route_to("outgoing_messages#index")
    end

    it "routes to #new" do
      expect(:get => "/api/outgoing_messages/new").to route_to("outgoing_messages#new")
    end

    it "routes to #show" do
      expect(:get => "/api/outgoing_messages/1").to route_to("outgoing_messages#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/outgoing_messages").to route_to("outgoing_messages#create")
    end
  end
end
