class CboUserMailer < ApplicationMailer
  default from: 'youthline@boston.gov'

  def cbo_user_email(user)
    @user = user
    @url  = 'http://youthjobs.mapc.org/applicants?email=' + user.email + '&token=' + user.authentication_token
    mail(to: @user.email, subject: 'Important Next Steps for Choosing Successlink Applicants')
  end
end
