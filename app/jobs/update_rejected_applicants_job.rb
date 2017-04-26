class UpdateRejectedApplicantsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    not_chosen_applicants.each do |applicant|
      update_applicant_to_new_submission(applicant)
    end
  end

  private

  def not_chosen_applicants
    chosen_applicants = []
    chosen_applicants << Pick.where(status: :hire).pluck(:applicant_id)
    chosen_applicants << Requisition.where(status: :hire).pluck(:applicant_id)
    chosen_applicants.flatten!
    not_chosen_applicants = Applicant.all.pluck(:id) - chosen_applicants
    Applicant.find(not_chosen_applicants)
  end

  def update_applicant_to_new_submission(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to new submission: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"D10100"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to New Submission Failed for: ' + applicant.id.to_s
      Rails.logger.error response.status
      Rails.logger.error response.body
    end
  end
end
