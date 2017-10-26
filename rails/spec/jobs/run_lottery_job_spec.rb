require 'rails_helper'

RSpec.describe RunLotteryJob, type: :job do
  subject(:job) { RunLotteryJob.perform_later }

  it 'queues the job' do
    ActiveJob::Base.queue_adapter = :test
    expect { job }.to have_enqueued_job(RunLotteryJob)
      .on_queue("default")
  end

  it 'assigns lottery numbers to applicants' do
    FactoryGirl.create(:applicant)
    RunLotteryJob.perform_now
    expect(Applicant.last.lottery_number).to be
  end
end
