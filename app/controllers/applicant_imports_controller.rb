class ApplicantImportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    ImportApplicantsJob.perform_later
    render body: 'Applicants will be imported from ICIMs'
  end
end
