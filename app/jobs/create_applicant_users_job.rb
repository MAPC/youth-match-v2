class CreateApplicantUsersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.where(user: nil).each do |applicant|
      next if applicant.email.blank?
      user = User.create(email: applicant.email.downcase,
                         password: Devise.friendly_token.first(8),
                         applicant: applicant)
      if user.valid?
        ApplicantMailer.job_picker_email(user).deliver_later
        update_icims_status_to_candidate_employment_selection(applicant)
      else
        Rails.logger.error 'APPLICANT USER ACCOUNT CREATION ERROR Failed for: ' + applicant.id
      end
    end
  end

  private

  def update_icims_status_to_candidate_employment_selection(applicant)
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id
      req.body = %Q{ {"status":{"id":"C51218"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id
    end
  end
end
