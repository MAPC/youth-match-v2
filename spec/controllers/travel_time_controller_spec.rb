require 'rails_helper'

RSpec.describe TravelTimeController, type: :controller do

  describe "GET #get" do
    it "returns http success" do
      pending "Not going to test importing the grid at this time."
      get :get, params: { origin: '0,0',  destination: '0,0' }
      expect(response).to have_http_status(:success)
    end

    it "returns an error when you do not provide valid origin" do
      get :get, params: { destination: '0,0' }
      expect(response).to have_http_status(422)
    end

    it "returns an error when you do not provide valid destination" do
      get :get, params: { origin: '0,0' }
      expect(response).to have_http_status(422)
    end
  end

end
