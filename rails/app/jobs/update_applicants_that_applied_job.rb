class UpdateApplicantsThatAppliedJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.joins(:requisitions).distinct.each do |applicant|
      sleep 1
      update_applicant_to_candidate_employment_selection(applicant)
    end
  end

  def update_applicant_to_candidate_employment_selection(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to employment selection: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/applicantworkflows/" + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C51218"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
      retry_job wait: 5.minutes, queue: :default if response.status == 500
    end
  end
end
