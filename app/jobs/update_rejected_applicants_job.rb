class UpdateRejectedApplicantsJob < ApplicationJob
  include IcimsQueryable
  queue_as :default

  def perform(*args)
    not_chosen_applicants.each do |applicant|
      update_applicant_to_new_submission(applicant) if status_is_candidate_employment_selection?(applicant)
    end
  end

  private

  def not_chosen_applicants
    chosen_applicants = Pick.all.pluck(:applicant_id)
    not_chosen_applicants = Applicant.all.pluck(:id) - chosen_applicants
    Applicant.find(not_chosen_applicants)
  end

  def status_is_candidate_employment_selection?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    Rails.logger.info response['status']['id'].to_s
    response['status']['id'] == 'C51218' ? true : false
  end

  def update_applicant_to_new_submission(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to new submission: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/applicantworkflows/" + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"D10100"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to New Submission Failed for: ' + applicant.icims_id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end
end
