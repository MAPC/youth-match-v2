# Preview all emails at http://localhost:3000/rails/mailers/job_offer_mailer
class JobOfferMailerPreview < ActionMailer::Preview
  def job_offer_email
    JobOfferMailer.job_offer_email(User.last)
  end
end
