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
      else
        Rails.logger.error 'APPLICANT USER ACCOUNT CREATION ERROR Failed for: ' + applicant.id
      end
    end
  end
end
