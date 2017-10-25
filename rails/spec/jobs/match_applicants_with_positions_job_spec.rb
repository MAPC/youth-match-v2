require 'rails_helper'

RSpec.describe MatchApplicantsWithPositionsJob, type: :job do

  subject(:job) { MatchApplicantsWithPositionsJob.perform_later }

  it 'queues the job' do
    ActiveJob::Base.queue_adapter = :test
    expect { job }.to have_enqueued_job(MatchApplicantsWithPositionsJob)
      .on_queue("default")
  end

  it 'matches the applicants with positions' do
    FactoryGirl.create_list(:applicant, 20)
    FactoryGirl.create_list(:position, 5)
    Applicant.all.each do |applicant|
      Position.all.each do |position|
        FactoryGirl.create(:preference, applicant: applicant, position: position)
      end
    end

    MatchApplicantsWithPositionsJob.perform_now
    expect(Offer.count).to eq(Position.sum(:open_positions))
    expect(Applicant.chosen.count).to eq(0)
  end

  it 'can run a second lottery for unaccepted applicants' do
    FactoryGirl.create_list(:applicant, 20)
    FactoryGirl.create_list(:position, 5)
    Applicant.all.each do |applicant|
      Position.all.each do |position|
        FactoryGirl.create(:preference, applicant: applicant, position: position)
      end
    end

    MatchApplicantsWithPositionsJob.perform_now
    Offer.update_all(accepted: 'expired')
    Offer.first.update(accepted: 'yes')
    Offer.last.update(accepted: 'no_bottom_waitlist')

    MatchApplicantsWithPositionsJob.perform_now
    expect(Offer.where(accepted: 'waiting').count).to eq(Position.sum(:open_positions) - 1)
  end
end
