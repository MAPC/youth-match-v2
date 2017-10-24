require "rails_helper"

RSpec.describe ApplicantMailer, type: :mailer do
  describe "job_picker" do
    user = FactoryGirl.create(:user)
    let(:mail) { ApplicantMailer.job_picker_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Important Next Steps for Successlink Summer Jobs")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["youthline@boston.gov"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Dear SuccessLink Applicant")
    end
  end

  describe "decline_offer" do
    user = FactoryGirl.create(:user)
    let(:mail) { ApplicantMailer.decline_offer_email(user) } # command where applicant declines an offer
    it "renders the headers" do
      expect(mail.subject).to eq("Information on your Declined Successlink Offer")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["youthline@boston.gov"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Dear SuccessLink Applicant")
    end
  end
end
