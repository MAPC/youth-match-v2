require 'rails_helper'

RSpec.describe "Check lottery status", type: :request do
  describe "GET /expire-lottery-status" do
    it "works!" do
      get expire_lottery_status_path
      expect(response).to have_http_status(200)
      expect(response.body).to eq('Empty')
    end
  end
end
