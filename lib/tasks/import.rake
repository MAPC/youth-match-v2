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

  desc "Import applicants from ICIMS"
  task applicants_from_icims: :environment do
    response = Faraday.get('https://api.icims.com/customers/6405/search/people?searchJson=%7B%22filters%22%3A%20%5B%7B%22name%22%3A%20%22applicantworkflow.job.id%22%2C%22value%22%3A%20%5B%2212634%22%5D%2C%22operator%22%3A%20%22%3D%22%7D%5D%20%7D', {},
                            {"authorization" => "Basic #{Rails.application.secrets.icims_authorization_key}"} )
    applicants = JSON.parse(response.body)["searchResults"].map { |x| x["id"] }
    applicants.each do |applicant_id|
      next if Applicant.find_by_icims_id(applicant_id)
      applicant_information = get_person_from_icims(applicant_id)
      applicant_home_address_geocoded = geocode_address(applicant_information)
      applicant = Applicant.new(first_name: applicant_information["firstname"],
                                last_name: applicant_information["lastname"],
                                email: applicant_information["email"],
                                icims_id: applicant_id,
                                prefers_nearby: boolean(applicant_information["field29946"]),
                                has_transit_pass: boolean(applicant_information["field36999"]),
                                receive_text_messages: boolean(applicant_information["field50527"]),
                                phone: mobile_phone(applicant_information),
                                guardian_name: applicant_information["field51088"],
                                guardian_phone: applicant_information["field51089"],
                                guardian_email: applicant_information["field51090"],
                                location: "POINT(" + applicant_home_address_geocoded[1].to_s + " " + applicant_home_address_geocoded[0].to_s + ")")
      thank(appliant.phone)
      applicant.save
    end
  end

  desc "Import positions from ICIMS"
  task positions_from_icims: :environment do
    # get position IDS from icims
    # iterate through positions to get position information
    Position.new(# icims_id: ,
                 # title: ,
                 # category: ,
                 # location: "POINT(" + row['X'] + " " + row['Y'] + ")" # lon lat,
      )
  end

  private

  def get_person_from_icims(applicant_id)
    response = Faraday.get("https://api.icims.com/customers/7383/people/#{applicant_id}",
                           {"fields" => "firstname,lastname,addresses,phones,email,birthdate,
                            jobtitle,job,field23848,field29946,field36999,field50527, field51088,
                            field51089,field51090"},
                           {"authorization" => "Basic #{Rails.application.secrets.icims_authorization_key}"})
    JSON.parse(response.body)
  end

  def geocode_address(applicant)
    street_address = applicant["addresses"].each { |address| break address["addressstreet1"] if address["addresstype"]["value"] == "Home" }
    response = Faraday.get("https://search.mapzen.com/v1/search?text=#{street_address}
                                                               &size=1
                                                               &focus.point.lat=42.3550591
                                                               &focus.point.lon=-71.0635035
                                                               &api_key=#{Rails.application.secrets.mapzen_api_key}")
    JSON.parse(response.body)["features"][0]["geometry"]["coordinates"]
  end

  def mobile_phone(applicant)
    applicant["phones"].each do |phone|
      next if phone["phonetype"].blank?
      break phone["phonenumber"].gsub(/\D/, '') if phone["phonetype"]["value"] = "Mobile"
    end
  end

  def thank(phone)
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    message = client.messages.create from: '6176168535', to: phone, body: 'Thank you for applying to the 2017 SuccessLink Lottery. We have received your application! You will receive a text and email with your status in the lottery after 3/31.'
  end

  def boolean(data)
    data.to_s == "Yes"
  end
end
