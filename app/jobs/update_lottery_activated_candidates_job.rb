class UpdateLotteryActivatedCandidatesJob < ApplicationJob
  queue_as :default

  def perform(applicant)
    update_applicant_to_lottery_activated(applicant) if status_is_new_submission?(applicant)
  end

  private

  def status_is_new_submission?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    Rails.logger.info response['status'].to_s
    response['status']['id'] == 'D10100' ? true : false
  end

  def update_applicant_to_lottery_activated(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery activated: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/applicantworkflows/" + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38354"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Activated Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
      retry_job wait: 5.minutes, queue: :default if response.status == 500
    end
  end

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/7383/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end
end
