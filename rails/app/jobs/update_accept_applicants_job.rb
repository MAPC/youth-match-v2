class UpdateAcceptApplicantsJob < ApplicationJob
  queue_as :default

  def perform(offer_id)
    offer = Offer.find(offer_id)
    update_applicant_to_placement_accepted(offer.applicant)
    associate_applicant_with_position(offer.applicant_id, offer.position_id)
  end

  private

  def update_applicant_to_placement_accepted(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to placement accepted: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/applicantworkflows/" + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C36951"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Placement Accepted Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def associate_applicant_with_position(applicant_id, position_id)
    applicant = Applicant.find(applicant_id)
    position = Position.find(position_id)
    Rails.logger.info "Associate applicant iCIMS ID #{applicant.icims_id} with position: #{applicant.id}"
    response = Faraday.post do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/applicantworkflows"
      req.body = %Q{ {"baseprofile":#{position.icims_id},"status":{"id":"C36951"},"associatedprofile":#{applicant.icims_id}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant with Position Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
      retry_job wait: 5.minutes, queue: :default if response.status == 500
    end
  end
end
