# Preview all emails at http://localhost:3000/rails/mailers/staff
class StaffPreview < ActionMailer::Preview
  def staff_login_email
    user = FactoryGirl.build(:staff_user)
    password = Devise.friendly_token(8)
    StaffMailer.staff_login_email(user, password)
  end
end
