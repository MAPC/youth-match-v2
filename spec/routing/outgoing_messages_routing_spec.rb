require "rails_helper"

RSpec.describe OutgoingMessagesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/outgoing_messages").to route_to("outgoing_messages#index")
    end

    it "routes to #new" do
      expect(:get => "/outgoing_messages/new").to route_to("outgoing_messages#new")
    end

    it "routes to #show" do
      expect(:get => "/outgoing_messages/1").to route_to("outgoing_messages#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/outgoing_messages/1/edit").to route_to("outgoing_messages#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/outgoing_messages").to route_to("outgoing_messages#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/outgoing_messages/1").to route_to("outgoing_messages#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/outgoing_messages/1").to route_to("outgoing_messages#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/outgoing_messages/1").to route_to("outgoing_messages#destroy", :id => "1")
    end

  end
end
