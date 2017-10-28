require 'rails_helper'

RSpec.describe ExpireLotteryJob, type: :job do
  subject(:job) { ExpireLotteryJob.perform_later }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(ExpireLotteryJob)
      .on_queue("expire_lottery")
  end

  it 'expires open offers' do
    offer = FactoryGirl.create(:offer, accepted: 'offer_sent')
    ExpireLotteryJob.perform_now
    offer.reload
    expect(offer.accepted).to eq('expired')
  end
end
