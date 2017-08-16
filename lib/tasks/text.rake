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

  desc 'Text folks who were picked more than once'
  task multiple_picks: :environment do
    applicant_ids = Pick.find_by_sql('SELECT applicant_id, COUNT(*) FROM picks GROUP BY applicant_id HAVING COUNT(*) > 1').pluck(:applicant_id)
    applicants = Applicant.find(applicant_ids)
    applicants.each do |applicant|
      if applicant.receive_text_messages
        notify(applicant.mobile_phone) if applicant.mobile_phone && applicant.mobile_phone.length == 10
      end
    end
  end

  desc 'Text young people and parents who did not reply'
  task no_responses: :environment do
    Offer.where(accepted: 'waiting').each do |offer|
      applicant = Applicant.find(offer.applicant_id)
      if applicant.receive_text_messages
        young_person(applicant.mobile_phone) if applicant.mobile_phone && applicant.mobile_phone.length == 10
        parent(applicant.guardian_phone) if applicant.guardian_phone && applicant.guardian_phone.length == 10
      end
    end
  end

  desc 'Text accepted applicants'
  task accepted_responses: :environment do
    Offer.where(accepted: 'yes').each do |offer|
      applicant = Applicant.find(offer.applicant_id)
      if applicant.receive_text_messages
        onboard_reminder(applicant.mobile_phone) if applicant.mobile_phone && applicant.mobile_phone.length == 10
      end
    end
  end

  desc 'Exempt reminder about onboarding'
  task onboarding_reminder: :environment do
    Pick.all.each do |pick|
      applicant = Applicant.find(pick.applicant_id)
      if applicant.receive_text_messages
        onboard_reminder_2(applicant.mobile_phone) if applicant.mobile_phone && applicant.mobile_phone.length == 10
      end
    end
  end

  desc 'Text accepted applicants about onboarding 2'
  task accepted_responses2: :environment do
    Offer.where(accepted: 'yes').each do |offer|
      applicant = Applicant.find(offer.applicant_id)
      if applicant.receive_text_messages
        onboard_reminder_2(applicant.mobile_phone) if applicant.mobile_phone && applicant.mobile_phone.length == 10
      end
    end
  end

  desc 'Text control group applicants'
  task control_group: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'yee_non_participants.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each do |row|
      control_group_message(row['mobile_phone']) if row['mobile_phone']
    end
  end

  private

  def young_person(phone)
    begin
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'Congrats, you got a summer job offer! Please check your email. You must still upload documents to your City of Boston profile and complete work tasks.'
    rescue Twilio::REST::RequestError => e
      puts e
    end
  end

  def parent(phone)
    begin
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'The City of Boston has offered your child a summer job! Please remind them to check their email to upload documents to their profile and complete work tasks.'
    rescue Twilio::REST::RequestError => e
      puts e
    end
  end

  def onboard_reminder(phone)
    begin
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'Complete your summer job hiring! Please bring uploaded documents to “GET HIRED” on Saturday, June 3rd, 2017 9am-5pm at YEE: 1483 Tremont St, Boston, MA 02120'
    rescue Twilio::REST::RequestError => e
      puts e
    end
  end

  def onboard_reminder_2(phone)
    begin
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'To finish the City of Boston summer job hiring process, you MUST upload documents bit.ly/summerjobdocs & complete tasks in your account bit.ly/successlinklogin. You must also bring those documents in person to verify at YEE: 1483 Tremont St, Boston, MA 02120, weekdays 2-7pm, OR come this Saturday 9-1.'
    rescue Twilio::REST::RequestError => e
      puts e
    end
  end

  def notify(phone)
    begin
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: "You’ve been selected by multiple job sites.Please contact the YEE office at 617-635-4202 to pick your job by 5/17 @ 5:00 pm or we'll select your job for you."
    rescue Twilio::REST::RequestError => e
      puts e
    end
  end

  def control_group_message(phone)
    begin
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'You have been selected by the Mayor’s Office of Workforce Development for a chance to win a free iPad Mini by taking a 10 minute survey about your summer experiences!  You must take the survey by midnight Friday September 1st to be entered to win!  To fill out the survey, follow this link: http://bit.ly/cityofbostonsurvey'
    rescue Twilio::REST::RequestError => e
      puts e
    end
  end
end
