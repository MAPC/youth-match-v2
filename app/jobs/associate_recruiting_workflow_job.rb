class AssociateRecruitingWorkflowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Applicant.joins(:requisitions).distinct.each do |applicant|
    #   update_applicant_to_candidate_employment_selection(applicant)
    # end
    Requisition.where(status: :hire).each do |requisition|
      associate_applicant_with_position(requisition.applicant_id, requisition.position_id)
      update_applicant_to_selected(requisition.applicant)
    end
    Pick.where(status: :hire).each do |pick|
      associate_applicant_with_position(pick.applicant_id, pick.position_id)
      update_applicant_to_selected(pick.applicant)
    end
  end

  private

  def associate_applicant_with_position(applicant_id, position_id)
    applicant = Applicant.find(applicant_id)
    position = Position.find(position_id)
    Rails.logger.info "Associate applicant iCIMS ID #{applicant.icims_id} with position: #{applicant.id}"
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows'
      req.body = %Q{ {"baseprofile":#{position.icims_id},"status":{"id":"C2028"},"associatedprofile":#{applicant.icims_id}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant with Position Failed for: ' + applicant.id.to_s
      Rails.logger.error response.status
      Rails.logger.error response.body
    end
  end

  def update_applicant_to_selected(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to selected: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C2028"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Selected by Site Failed for: ' + applicant.id.to_s
      Rails.logger.error response.status
      Rails.logger.error response.body
    end
  end

  def update_applicant_to_candidate_employment_selection(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to employment selection: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C51218"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
      Rails.logger.error response.status
      Rails.logger.error response.body
    end
  end
end
