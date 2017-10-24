class ApplicantMailer < ApplicationMailer
  default from: 'youthline@boston.gov'

  def job_picker_email(user)
    @user = user
    @url  = "http://youthjobs.mapc.org/login?email=#{user.email}&token=#{user.authentication_token}"
    mail(to: @user.email, subject: 'Important Next Steps for Successlink Summer Jobs')
  end

  def decline_offer_email(user)
    mail(to: user.email, subject: 'Information on your Declined Successlink Offer')
  end
end
