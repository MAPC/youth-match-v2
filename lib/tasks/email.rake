namespace :email do
  desc "Email applicants the job picker"
  task applicant_job_picker: :environment do
    Applicant.where(user: nil).each do |applicant|
      next if applicant.email.blank?
      user = User.create(email: applicant.email.downcase,
                         password: Devise.friendly_token.first(8),
                         applicant: applicant)
      if user.valid?
        ApplicantMailer.job_picker_email(user).deliver_now
      else
        puts 'Failed for: ' + applicant.id
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
end
