require 'csv'
namespace :import do
  desc 'Import seed data'
  task seed: :environment do
    puts "\nImporting the grid"
    sh "psql #{Rails.configuration.database_configuration[Rails.env]['database']} < lib/seeds/boxes.sql"
    puts "\n== Importing grid travel times.
          WARNING: Importing this 1GB file will take a while. =="
    sh "psql #{Rails.configuration.database_configuration[Rails.env]['database']} < lib/seeds/travel_times.sql"
  end

  desc "Import applicant test data"
  task applicant_test_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'applicants.csv'))
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = Applicant.new
      a.first_name = "FirstName #{index}"
      a.last_name = "LastName #{index}"
      a.email = "#{index}@email.com"
      a.icims_id = index
      a.interests = [row['interest1'],row['interest2'],row['interest3']]
      a.prefers_nearby = row['prefers_ne'].to_s == 'TRUE' ? true : false
      a.has_transit_pass = row['has_transi'].to_s == 'TRUE' ? true : false
      a.location = "POINT(" + row['X'] + " " + row['Y'] + ")" # lon lat
      a.save
    end
  end

  desc "Import position test data"
  task position_test_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'positions.csv'))
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = Position.new
      a.title = "Test Position #{index}"
      a.icims_id = index
      a.category = row['category']
      a.location = "POINT(" + row['X'] + " " + row['Y'] + ")" # lon lat
      a.save
    end
  end
end
