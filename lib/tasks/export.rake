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
end
