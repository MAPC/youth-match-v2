class UpdateLotteryActivatedCandidatesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.all.each do |applicant|
      update_applicant_to_lottery_activated(applicant) if status_is_new_submission?(applicant)
    end
  end

  private

  def status_is_new_submission?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    response['status']['id'] == 'D10100' ? true : false
  end

  def update_applicant_to_lottery_activated(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery activated: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38354"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Activated Failed for: ' + applicant.id.to_s
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
