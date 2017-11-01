require 'rails_helper'

RSpec.describe ValidateEmailJob, type: :job do
  subject(:job) { ValidateEmailJob.perform_later(1) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(ValidateEmailJob)
      .with(1)
      .on_queue("default")
  end

  it 'validates the email' do
    applicant = FactoryGirl.create(:applicant, email: 'mzagaja@mapc.org')
    VCR.use_cassette("mailgun") do
      ValidateEmailJob.perform_now(applicant.id)
      expect { applicant.reload }.to change{ applicant.valid_email }.from(nil).to(true)
    end
  end
end
