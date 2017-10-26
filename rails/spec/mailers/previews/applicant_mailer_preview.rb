# Preview all emails at http://localhost:3000/rails/mailers/applicant_mailer
class ApplicantMailerPreview < ActionMailer::Preview
  def job_picker_email
    user = FactoryGirl.build(:user)
    ApplicantMailer.job_picker_email(user)
  end
end
