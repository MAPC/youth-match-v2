require 'rails_helper'

RSpec.describe BuildTravelTimePreferenceJob, type: :job do
  let(:applicant) { FactoryGirl.create(:applicant) }
  let(:position) { FactoryGirl.create(:position) }

  subject(:job) { BuildTravelTimePreferenceJob.perform_later(applicant.id, position.id) }

  it 'queues the job' do
    ActiveJob::Base.queue_adapter = :test
    expect { job }.to have_enqueued_job(BuildTravelTimePreferenceJob)
      .with(applicant.id, position.id)
      .on_queue("default")
  end

  it 'calculates a travel time score' do
    BuildTravelTimePreferenceJob.perform_now(applicant.id, position.id)
    expect(Preference.count).to eq(1)
    expect(Preference.last.travel_time_score).to be_present
  end
end
