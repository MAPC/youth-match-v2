class StaffMailer < ApplicationMailer
  default from: 'youthline@boston.gov'
  def staff_login_email(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Your YEE Staff Password')
  end
end
