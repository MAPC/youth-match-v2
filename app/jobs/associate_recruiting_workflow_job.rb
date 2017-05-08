class AssociateRecruitingWorkflowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    sample_from_first_job = Applicant.joins(:requisitions).distinct.first(100).pluck(:id)
    applicants_that_were_picked = Applicant.joins(:picks).distinct.pluck(:id)
    pick_ids_to_move = sample_from_first_job & applicants_that_were_picked
    Rails.logger.info pick_ids_to_move.to_s
    picks_to_move = Pick.find(pick_ids_to_move)
    picks_to_move.each do |pick|
      sleep 1
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
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
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
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end
end
