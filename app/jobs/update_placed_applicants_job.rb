class UpdatePlacedApplicantsJob < ApplicationJob
  queue_as :default

  def perform(applicant_id)
    applicant = Applicant.find(applicant_id)
    update_applicant_to_lottery_placed(applicant)
  end

  private

  def update_applicant_to_lottery_placed(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery placed: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38356"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    unless response.blank? || response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Placed Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end
end
