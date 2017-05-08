class UpdateRejectedApplicantsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    not_chosen_applicants.each do |applicant|
      update_applicant_to_new_submission(applicant) if status_is_candidate_employment_selection?(applicant)
    end
  end

  private

  def not_chosen_applicants
    chosen_applicants = []
    chosen_applicants << Pick.all.pluck(:applicant_id)
    chosen_applicants.flatten!
    not_chosen_applicants = Applicant.all.pluck(:id) - chosen_applicants
    sample_from_first_job = Applicant.joins(:requisitions).distinct.first(100).pluck(:id)
    sample_not_chosen_applicants = not_chosen_applicants & sample_from_first_job
    Applicant.find(not_chosen_applicants)
  end

  def status_is_candidate_employment_selection?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    response['status']['id'] == 'C51218' ? true : false
  end

  def update_applicant_to_new_submission(applicant)
    sleep 1
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to new submission: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"D10100"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to New Submission Failed for: ' + applicant.icims_id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/7383/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end
end
