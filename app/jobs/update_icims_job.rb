class UpdateIcimsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Requisition.where(status: :hire).each do |requisition|
      associate_applicant_with_position(requisition.applicant, requisition.position)
      update_applicant_to_selected(requisition.applicant)
    end
    Pick.where(status: :hire).each do |pick|
      associate_applicant_with_position(pick.applicant, pick.position)
      update_applicant_to_selected(pick.applicant)
    end
    not_chosen_applicants.each do |applicant|
      update_applicant_to_new_submission(applicant)
    end
  end

  private

  def associate_applicant_with_position(applicant, position)
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows'
      req.body = %Q{ {"baseprofile":#{position.icims_id},"status":{"id":"C2028"},"associatedprofile":#{applicant.icims_id}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant with Position Failed for: ' + applicant.id.to_s
    end
  end

  def update_applicant_to_selected(applicant)
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C2028"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Selected by Site Failed for: ' + applicant.id.to_s
    end
  end

  def not_chosen_applicants
    chosen_applicants = []
    chosen_applicants << Pick.where(status: :hire).pluck(:applicant_id)
    chosen_applicants << Requisition.where(status: :hire).pluck(:applicant_id)
    chosen_applicants.flatten!
    not_chosen_applicants = Applicant.all.pluck(:id) - chosen_applicants
    Applicant.find(not_chosen_applicants)
  end

  def update_applicant_to_new_submission(applicant)
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"D10100"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to New Submission Failed for: ' + applicant.id.to_s
    end
  end
end
