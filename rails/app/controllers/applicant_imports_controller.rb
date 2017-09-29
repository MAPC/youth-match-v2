class ApplicantImportsController < ApplicationController
  def create
    ImportApplicantsJob.perform_later
    render body: 'Applicants will be imported from ICIMs'
  end
end
