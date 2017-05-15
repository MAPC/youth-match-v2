namespace :text do

  desc 'Text folks who were put in onboarding'
  task onboarded_applicants: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'yee_onboarding_text_message.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each do |row|
      applicant = Applicant.find_by(icims_id: row['Person : System ID'])
      next if applicant.blank?
      if applicant.receive_text_messages
        young_person(applicant.mobile_phone) if applicant.mobile_phone && applicant.mobile_phone.length == 10
        parent(applicant.guardian_phone) if applicant.guardian_phone && applicant.guardian_phone.length == 10
      end
    end
  end

  private

  def young_person(phone)
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'Congrats, you got a summer job offer! Please check your email. You must still upload documents to your City of Boston profile and complete work tasks.'
  end

  def parent(phone)
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'The City of Boston has offered your child a summer job! Please remind them to check their email to upload documents to their profile and complete work tasks.'
  end
end
