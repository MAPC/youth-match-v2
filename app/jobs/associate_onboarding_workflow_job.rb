class AssociateOnboardingWorkflowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Requisition.where(status: :hire).each do |requisition|
      associate_onboarding_with_position(requisition.applicant, requisition.position)
      update_applicant_to_selected(requisition.applicant)
    end
    Pick.where(status: :hire).each do |pick|
      associate_onboarding_with_position(pick.applicant, pick.position)
      update_applicant_to_selected(pick.applicant)
    end
  end

  private

  def associate_onboarding_with_position(applicant, position)
    onboard_workflow = get_onboard_workflow(applicant)
    Rails.logger.info "Associate applicant iCIMS ID #{applicant.icims_id} with position: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/onboardworkflows/#{onboard_workflow}'
      req.body = %Q{ { "job":#{position.icims_id} } }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant with Position Failed for: ' + applicant.id.to_s
      Rails.logger.error response.status
      Rails.logger.error response.body
    end
  end

  def get_onboard_workflow(applicant)
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/7383/search/applicantworkflows'
      req.body = %Q{ {"filters":[{"name":"onboardworkflow.associatedprofile.person","value":["#{applicant.icims_id}"],"operator":"="},{"name":"onboardworkflow.status.listnode","value":["D37002023004"],"operator":"!="}],"operator":"&"} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    response['searchResults'].pluck('id').first
  end
end
