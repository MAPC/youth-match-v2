namespace :export do
  desc 'Export URLs for CBO Partners from Users'
  task cbo_users: :environment do
    CSV.open('cbo_logins.csv', 'wb') do |csv|
      csv << %w(Email URL)
      User.all.each do |user|
        csv << [user.email, 'http://youthjobs.mapc.org/applicants?email=' + user.email + '&token=' + user.authentication_token]
      end
    end
  end

  task 'Export URLs for Applicant Users'
  task applicant_users: :environment do
    CSV.open('applicant_logins.csv', 'wb') do |csv|
      csv << %w(Email URL)
      User.joins(:applicant).each do |user|
        csv << [user.email, 'http://youthjobs.mapc.org/jobs?email=' + user.email + '&token=' + user.authentication_token]
      end
    end
  end

  task 'Export CSV of results'
  task offers_csv: :environment do
    offers = Offer.all.includes(:applicant).includes(:position)
    CSV.open('offers_all.csv', 'wb') do |csv|
      csv << offers.first.applicant.attributes.keys + offers.first.position.attributes.keys
      offers.each do |offer|
        csv << offer.applicant.attributes.values + offer.position.attributes.values
      end
    end
  end
end
