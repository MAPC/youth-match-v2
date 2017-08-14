# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env.development? || Rails.env.test?
  sh "pg_restore -Fc -d #{Rails.configuration.database_configuration[Rails.env]['database']} lib/seeds/travel_times.dump" || true
  sh "pg_restore -Fc -d #{Rails.configuration.database_configuration[Rails.env]['database']} lib/seeds/boxes.dump" || true
else
  sh "pg_restore -Fc -h #{Rails.configuration.database_configuration[Rails.env]['host']} -U #{Rails.configuration.database_configuration[Rails.env]['username']} -w -d #{Rails.configuration.database_configuration[Rails.env]['database']} lib/seeds/travel_times.dump" || true
  sh "pg_restore -Fc -h #{Rails.configuration.database_configuration[Rails.env]['host']} -U #{Rails.configuration.database_configuration[Rails.env]['username']} -w -d #{Rails.configuration.database_configuration[Rails.env]['database']} lib/seeds/boxes.dump" || true
end
