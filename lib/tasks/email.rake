namespace :email do
  desc "Email applicants the job picker"
  task applicant_job_picker: :environment do
    Applicant.where(user: nil).each do |applicant|
      next if applicant.email.blank?
      user = User.create(email: applicant.email.downcase,
                         password: Devise.friendly_token.first(8),
                         applicant: applicant)
      if user.valid?
        # ApplicantMailer.job_picker_email(user).deliver_now
        update_icims_status_to_candidate_employment_selection(applicant)
      else
        puts 'APPLICANT USER ACCOUNT CREATION ERROR Failed for: ' + applicant.id
      end
    end
  end

  desc 'Create user accounts for CBOs'
  task create_cbo_accounts: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'partner-emails-6-fixed.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row|
      positions = Position.where(site_name: row['Organization Name'])
      user = User.create(email: row['Primary Contact Email'],
                         password: Devise.friendly_token.first(8),
                         positions: positions)
      puts row['Primary Contact Email'] if user.blank?
      next if user.blank?
      CboUserMailer.cbo_user_email(user).deliver_now
    end
  end

  desc 'Create User Accounts for Applicants'
  task create_applicant_accounts: :environment do
    Applicant.where(user: nil).each do |applicant|
      next if applicant.email.blank?
      user = User.create(email: applicant.email.downcase,
                         password: Devise.friendly_token.first(8),
                         applicant: applicant)
    end
  end

  desc 'Email a user their job offer'
  task email_lottery_job_offer: :environment do
    Applicant.chosen.first(30).each do |applicant|
      JobOfferMailer.job_offer_email(applicant.user)
    end
  end

  desc 'Update user accounts'
  task user_test_emails: :environment do
    Applicant.chosen.first(30).each_with_index do |applicant, index|
      if index.between?(0,4)
        applicant.user.update(email: 'princewill.dimgba@boston.gov')
      elsif index.between?(5,9)
        applicant.user.update(email: 'linda.monteiro@boston.gov')
      elsif index.between?(10,14)
        applicant.user.update(email: 'tierra.lyons@boston.gov')
      elsif index.between?(15,19)
        applicant.user.update(email: 'ann.braga@boston.gov')
      elsif index.between?(20,24)
        applicant.user.update(email: 'rashad.cope@boston.gov')
      elsif index.between?(25,29)
        applicant.user.update(email: 'deron.jackson@boston.gov')
      end
    end
  end

  private

  def update_icims_status_to_candidate_employment_selection(applicant)
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/7383/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C51218"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id
    end
  end
end
