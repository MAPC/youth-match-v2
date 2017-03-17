require "rails_helper"

RSpec.describe OffersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/offers").to route_to("offers#index")
    end

    it "routes to #new" do
      expect(:get => "/api/offers/new").to route_to("offers#new")
    end

    it "routes to #show" do
      expect(:get => "/api/offers/1").to route_to("offers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/offers/1/edit").to route_to("offers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/offers").to route_to("offers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/offers/1").to route_to("offers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/offers/1").to route_to("offers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/offers/1").to route_to("offers#destroy", :id => "1")
    end

  end
end
