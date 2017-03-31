namespace :email do
  desc "Email applicants the job picker"
  task applicant_job_picker: :environment do
    Applicant.where(user: nil).each do |applicant|
      user = User.create(email: applicant.email,
                         password: Devise.friendly_token.first(8),
                         applicant: applicant)
      ApplicantMailer.job_picker_email(user).deliver_now
    end
  end

  desc 'Create user accounts for CBOs'
  task create_cbo_accounts: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'partner-emails.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row|
      positions = Position.where(site_name: row['Organization Name'])
      user = User.create(email: row['Primary Contact Email'],
                         password: Devise.friendly_token.first(8),
                         positions: positions)
      CboUserMailer.cbo_user_email(user).deliver_now
    end
  end
end
