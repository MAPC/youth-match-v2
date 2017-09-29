require 'rails_helper'

RSpec.describe ImportApplicantsJob, :vcr, type: :job do
  pending 'cannot easily test API from remote server'
  # it 'should import applicants' do
  #   ImportApplicantsJob.perform_now
  #   expect(Applicant.all.count).to be > 0
  # end
end
