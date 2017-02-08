namespace :import do
  desc 'Import seed data'
  task seed: :environment do
    puts "\nImporting the grid"
    sh "psql #{Rails.configuration.database_configuration[Rails.env]['database']} < lib/seeds/boxes.sql"
    puts "\n== Importing grid travel times.
          WARNING: Importing this 1GB file will take a while. =="
    sh "psql #{Rails.configuration.database_configuration[Rails.env]['database']} < lib/seeds/travel_times.sql"
  end
end
