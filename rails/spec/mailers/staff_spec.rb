require "rails_helper"

RSpec.describe StaffMailer, type: :mailer do
  describe "staff login email" do
    generated_password = Devise.friendly_token(8)
    user = FactoryGirl.create(:user, password: generated_password)
    let(:mail) { StaffMailer.staff_login_email(user, generated_password) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your YEE Staff Password")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["youthline@boston.gov"])
    end

    it "includes the username and password" do
      expect(mail.body.encoded).to match(user.email)
      expect(mail.body.encoded).to match(generated_password)
    end
  end
end
