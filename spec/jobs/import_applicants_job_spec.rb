require 'rails_helper'

RSpec.describe ImportApplicantsJob, :vcr, type: :job do
  it 'should import applicants' do
    ImportApplicantsJob.perform_now
    expect(Applicant.all.count).to be > 0
  end
end
