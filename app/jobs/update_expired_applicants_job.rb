class UpdateExpiredApplicantsJob < ApplicationJob
  queue_as :default

  def perform(offer_id)
    offer = Offer.find(offer_id)
    update_applicant_to_lottery_expired(offer.applicant)
  end

  private

  def update_applicant_to_lottery_expired(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery expired: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38355"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 90
      req.options.open_timeout = 90
    end
    unless response.blank? || response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Expired Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end
end
