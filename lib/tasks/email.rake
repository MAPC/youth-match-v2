namespace :email do
  desc "Email applicants the job picker"
  task applicant_job_picker: :environment do
    Applicant.where(user: nil).each do |applicant|
      user = User.create(email: applicant.email,
                         password: Devise.friendly_token.first(8),
                         applicant: applicant)
      ApplicantMailer.job_picker_email(user).deliver_now
    end
  end
end
