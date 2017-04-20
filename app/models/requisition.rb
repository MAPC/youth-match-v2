class Requisition < ApplicationRecord
  belongs_to :applicant
  belongs_to :position
  enum status: [:interested, :hire, :do_not_hire]
  after_save :update_icims

  private

  def update_icims
    if self.status == 'hire'
      associate_applicant_with_position(self.applicant, self.position)
      update_applicant_to_selected(self.applicant)
    else
      update_applicant_to_candidate_employment_selection(self.applicant)
    end
  end

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

  def update_applicant_to_candidate_employment_selection(applicant)
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C51218"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
    end
  end
end
