require 'rails_helper'

RSpec.describe BuildPreferenceListsJob, type: :job do

  subject(:job) { BuildPreferenceListsJob.perform_later }

  it 'queues the job' do
    ActiveJob::Base.queue_adapter = :test
    expect { job }.to have_enqueued_job(BuildPreferenceListsJob)
      .on_queue("default")
  end

  it 'calculates the match scores' do
    applicant = FactoryGirl.create(:applicant)
    position1 = FactoryGirl.create(:position)
    position2 = FactoryGirl.create(:position)
    preference1 = FactoryGirl.create(:preference, applicant: applicant, position: position1)
    preference2 = FactoryGirl.create(:preference, applicant: applicant, position: position2)
    BuildPreferenceListsJob.perform_now
    expect(Preference.count).to eq(2)
    expect(Preference.first.score).to be_present
    expect(Preference.second.score).to be_present
  end
end
