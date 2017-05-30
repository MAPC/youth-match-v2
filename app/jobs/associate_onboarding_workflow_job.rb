class AssociateOnboardingWorkflowJob < ApplicationJob
  queue_as :default

  def perform(applicant_id, onboard_workflow_id)
    associate_onboarding_with_position(applicant_id, onboard_workflow_id)
  end

  private

  def associate_onboarding_with_position(applicant_id, onboard_workflow)
    position = get_position(applicant_id)
    if position.blank?
      Rails.logger.error "No position found for applicant: #{applicant_id}"
      return nil
    end
    Rails.logger.info "Associate applicant iCIMS ID #{applicant_id} with position iCIMS ID: #{position.icims_id}"
    response = Faraday.patch do |req|
      req.url "https://api.icims.com/customers/6405/onboardworkflows/#{onboard_workflow}"
      req.body = %Q{ { "job":#{position.icims_id} } }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant Onboard Workflow with Position Failed for: ' + applicant_id.to_s
      Rails.logger.error response.status
      Rails.logger.error response.body
    end
  end

  def get_position(applicant_icims_id)
    applicant = Applicant.find_by(icims_id: applicant_icims_id)
    if applicant.blank?
      Rails.logger.error "No applicant found for applicant: #{applicant_icims_id}"
      return nil
    end
    offer = Offer.find_by(applicant_id: applicant.id, accepted: 'yes')
    if offer.blank?
      Rails.logger.error "No offer found for applicant: #{applicant_icims_id}"
      return nil
    end
    Position.find(offer.position_id)
  end
end
