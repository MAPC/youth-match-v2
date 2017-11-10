require 'rails_helper'

RSpec.describe OfferEmailsController, type: :controller do
  it 'emails offers to applicants that were not emailed' do
    user = FactoryGirl.create(:user_with_applicant)
    sign_in user
    offer = FactoryGirl.create(:offer, applicant: user.applicant)
    expect { post :create, headers: { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json', 'authorization' => "Token token=#{user.authentication_token}, email=#{user.email}" } }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
  end
end
