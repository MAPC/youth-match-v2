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

  desc 'Import applicant test data'
  task applicant_test_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'applicants.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = Applicant.new
      a.first_name = "FirstName #{index}"
      a.last_name = "LastName #{index}"
      a.email = "#{index}@email.com"
      a.icims_id = index
      a.interests = [row['interest1'], row['interest2'], row['interest3']]
      a.prefers_nearby = row['prefers_ne'].to_s == 'TRUE' ? true : false
      a.has_transit_pass = row['has_transi'].to_s == 'TRUE' ? true : false
      a.location = "POINT(" + row['X'] + " " + row['Y'] + ")" # lon lat
      a.save
    end
  end

  desc 'Import position test data'
  task position_test_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'positions.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = Position.new
      a.title = "Test Position #{index}"
      a.icims_id = index
      a.category = row['category']
      a.location = "POINT(" + row['X'] + " " + row['Y'] + ")" # lon lat
      a.save
    end
  end

  desc 'Import applicants from ICIMS'
  task applicants_from_icims: :environment do
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/7383/search/applicantworkflows'
      req.body = '{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296","D10103"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634 "],"operator":"="}],"operator":"&"}'
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    workflows = JSON.parse(response.body)['searchResults'].map { |x| x['id'] }
    puts 'Number of applicants: ' + workflows.count.to_s
    workflows.each do |workflow_id|
      # ping the API for the information about the applicant
      workflow = Faraday.get("https://api.icims.com/customers/7383/applicantworkflows/#{workflow_id}",
                             {},
                             authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
      applicant_id = JSON.parse(workflow.body)['associatedprofile']['id']
      next if Applicant.find_by_icims_id(applicant_id)
      applicant_information = get_person_from_icims(applicant_id)
      puts 'Importing: ' + applicant_id.to_s
      applicant = Applicant.new(first_name: applicant_information['firstname'],
                                last_name: applicant_information['lastname'],
                                email: applicant_information['email'],
                                icims_id: applicant_id,
                                interests: [applicant_information['field51027'],
                                            applicant_information['field51034'],
                                            applicant_information['field51053'],
                                            applicant_information['field51054'],
                                            applicant_information['field51055']],
                                prefers_nearby: applicant_information['field51069'] == 'Distance to Home',
                                has_transit_pass: boolean(applicant_information['field36999']),
                                receive_text_messages: boolean(applicant_information['field50527']),
                                phone: mobile_phone(applicant_information),
                                guardian_name: applicant_information['field51088'],
                                guardian_phone: applicant_information['field51089'].try(:gsub, /\D/, ''),
                                guardian_email: applicant_information['field51090'],
                                in_school: boolean(applicant_information['field23807']),
                                school_type: applicant_information['field51062'],
                                bps_student: boolean(applicant_information['field23809']),
                                bps_school_name: applicant_information['field23810'],
                                current_grade_level: applicant_information['field23849'],
                                english_first_language: boolean(applicant_information['field23850']),
                                first_language: applicant_information['field23851'],
                                fluent_other_language: boolean(applicant_information['field23852']),
                                other_languages: applicant_information['field29895'].try(:pluck, 'value'),
                                held_successlink_job_before: boolean(applicant_information['field51122']),
                                previous_job_site: applicant_information['field51123'],
                                wants_to_return_to_previous_job: boolean(applicant_information['field51124']),
                                superteen_participant: boolean(applicant_information['field51125']),
                                participant_essay: applicant_information['field23873'],
                                participant_essay_attached_file: get_attached_essay(applicant_information),
                                location: geocode_address(applicant_information),
                                address: applicant_information['addresses'].each { |address| break address['addressstreet1'] if address['addresstype']['value'] == 'Home' })
      # thank(applicant.phone) if applicant.receive_text_messages
      applicant.save!
    end
  end

  desc 'Import positions from ICIMS'
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
                           { fields: 'firstname,middlename,lastname,email,phones,field50527,addresses,field50534,source,sourcename,field51088,field51089,field51090,field23807,field51062,field23809,field23810,field23849,field23850,field23851,field23852,field29895,field36999,field51069,field51122,field51123,field51124,field51125,field51027,field51034,field51053,field51054,field51055,field23872,field23873' },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

  def geocode_address(applicant)
    street_address = applicant['addresses'].each { |address| break address['addressstreet1'] if address['addresstype']['value'] == 'Home' }
    street_address.gsub!(/\s#\d+/i, '')
    response = Faraday.get("https://search.mapzen.com/v1/search?text=#{street_address}
                                                               &size=1
                                                               &focus.point.lat=42.3550591
                                                               &focus.point.lon=-71.0635035
                                                               &api_key=#{Rails.application.secrets.mapzen_api_key}")
    return nil if JSON.parse(response.body)['features'].count == 0
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return "POINT(" + coordinates[0].to_s + " " + coordinates[1].to_s + ")"
  end

  def get_attached_essay(applicant)
    return nil if applicant['field23872'].blank?
    file_location = applicant['field23872']['file'].gsub!('binary','text')
    Faraday.get(file_location, {}, authorization: "Basic #{Rails.application.secrets.icims_authorization_key}").body
  end

  def mobile_phone(applicant)
    applicant['phones'].each do |phone|
      next if phone['phonetype'].blank?
      return phone['phonenumber'].gsub(/\D/, '') if phone['phonetype']['value'] == 'Mobile'
    end
    return nil
  end

  def thank(phone)
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'Thank you for applying to the 2017 SuccessLink Lottery.
                           We have received your application! You will receive a text and
                           email with your status in the lottery after 3/31.'
  end

  def boolean(data)
    data.to_s == 'Yes'
  end
end
