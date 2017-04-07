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
    response = icims_search(type: 'applicantworkflows',
                            body: '{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634 "],"operator":"="}],"operator":"&"}')
    workflows = response['searchResults'].pluck('id') - Applicant.all.pluck(:workflow_id)
    puts 'Number of applicants: ' + workflows.count.to_s
    workflows.each do |workflow_id|
      workflow = icims_get(object: 'applicantworkflows', id: workflow_id)
      applicant_id = workflow['associatedprofile']['id']
      applicant_information = icims_get(object: 'people',
                                        fields: 'firstname,middlename,lastname,email,phones,field50527,addresses,field50534,source,sourcename,field51088,field51089,field51090,field23807,field51062,field23809,field23810,field23849,field23850,field23851,field23852,field29895,field36999,field51069,field51122,field51123,field51124,field51125,field51027,field51034,field51053,field51054,field51055,field23872,field23873',
                                        id: applicant_id)
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
                                mobile_phone: phone(applicant_information, 'Mobile'),
                                home_phone: phone(applicant_information, 'Home'),
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
                                location: geocode_applicant_address(applicant_information),
                                address: applicant_information['addresses'].each { |address| break address['addressstreet1'] if address['addresstype']['value'] == 'Home' },
                                workflow_id: workflow_id)
      # thank(applicant.mobile_phone) if applicant.mobile_phone && applicant.receive_text_messages
      applicant.save!
    end
  end

  desc 'Import applicants from production ICIMS'
  task applicants_from_prod: :environment do
    ImportApplicantsJob.perform_now
  end

  desc 'Import positions from ICIMS'
  task positions_from_icims: :environment do
    response = icims_search(type: 'jobs', body: '{"filters":[{"name":"job.jobtitle","value":["successlink"],"operator":"="}]}')
    jobs = response['searchResults'].pluck('id')
    puts 'Importing ' + jobs.count.to_s + 'jobs'
    jobs.each do |job_id|
      job = icims_get(object: 'jobs', id: job_id)
      job_address = get_address_from_icims(job['joblocation']['address'])
      position = Position.new(icims_id: job_id,
                              title: job['jobtitle'],
                              # category: ,
                              location: geocode_address(job_address['addressstreet1']))
      position.save!
    end
  end

  desc 'Import legacy site rehire data'
  task site_rehire_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'sites_applicants_2017.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = RehireSite.new
      a.site_name = row['Worksite']
      a.person_name = row['Name']
      a.icims_id = row['person_id']
      a.save
    end
  end

  desc 'Normalize duplicate rehire site data'
  task normalize_duplicate_sites: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'normalize_duplicate_sites.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = RehireSite.where(site_name: row['site1'])
      a.update_all(site_name: row['site2'])
    end
  end

  desc 'Import 2017 positions from Deron CSV file'
  task positions_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'dyee_2017_summer_positions_fixed.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = Position.new
      a.title = row['job_title']
      a.category = row['job_category']
      a.duties_responsbilities = row['duties_responsibilities']
      a.ideal_candidate = row['ideal_candidate']
      a.open_positions = row['open_positions']
      a.site_name = row['icims_name']
      a.external_application_url = row['app_1'] || row['app_2']
      a.primary_contact_person = row['primary_contact_person']
      a.primary_contact_person_title = row['primary_contact_person_title']
      a.primary_contact_person_phone = row['primary_contact_phone'].try(:gsub, /\D/, '')
      a.site_phone = row['phone'].try(:gsub, /\D/, '')
      a.location = RGeo::WKRep::WKBParser.new({}, support_ewkb: true).parse(row['the_geom'])
      a.address = row['address']
      a.save
    end
  end

  desc 'Import 2017 positions from Alicia cleaned CSV file'
  task positions_data_alicia: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'job-data-cleaned-alicia-descriptions.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row, index|
      a = Position.new
      a.title = row['job_title']
      a.category = row['Job Interest Area']
      a.duties_responsbilities = row['Key Duties and Responsibilities ']
      a.ideal_candidate = row['The Ideal Candidate for this Job:']
      a.open_positions = row['allottments']
      a.site_name = row['site name']
      a.external_application_url = row['App Link 1'] || row['App Link 2']
      a.primary_contact_person = row['Primary Contact Name']
      a.primary_contact_person_title = row['Primary Contact Title']
      a.primary_contact_person_phone = row['Primary Contact Phone'].try(:gsub, /\D/, '')
      a.location = geocode_address(row['street_address'])
      a.address = row['street_address']
      a.save
    end
  end

  desc 'Update allocation rules for partners'
  task allocation_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'exempt_partners_2017_100_percent.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    Rails.logger.info '======Updating Partner Allocation Rules======'
    csv.each_with_index do |row|
      user = User.find_by_email(row['Primary Contact Email'].downcase!)
      if user
        user.update(allocation_rule: 1)
      else
        Rails.logger.info 'Allocation update failed: ' + row['Primary Contact Email']
      end
    end
  end

  desc 'Import the Primary Contact EMail'
  task primary_contact_email: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'job-data-cleaned-alicia-descriptions.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each do |row|
      position = Position.find_by_title(row['job_title'])
      position.update(primary_contact_person_email: row['Primary Contact Email']) if position
    end
  end

  desc 'Check for missing workflow ids'
  task check_missing_workflows: :environment do
    local_workflows = Applicant.all.pluck(:workflow_id)
    remote_workflows = []
    current_count = 1000
    while current_count == 1000
      response = icims_search(type: 'applicantworkflows',
                              body: %Q{{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634"],"operator":"="},{"name":"applicantworkflow.id","value":["#{remote_workflows.last}"],"operator":">"}],"operator":"&"}})
      remote_workflows.push(*response['searchResults'].pluck('id'))
      current_count = response['searchResults'].pluck('id').count
    end
    puts remote_workflows - local_workflows
  end

  desc 'Update applicant neighborhood data'
  task update_applicant_neighborhoods: :environment do
    applicants = Applicant.all.pluck(:icims_id)
    applicants.each do |applicant_id|
      applicant_information = icims_get(object: 'people',
                                        fields: 'firstname,middlename,lastname,email,phones,field50527,addresses,field50534,source,sourcename,field51088,field51089,field51090,field23807,field51062,field23809,field23810,field23849,field23850,field23851,field23852,field29895,field36999,field51069,field51122,field51123,field51124,field51125,field51027,field51034,field51053,field51054,field51055,field23872,field23873',
                                        id: applicant_id)
      Applicant.find_by_icims_id(applicant_id).update(neighborhood: applicant_information['field50534']['value']) if applicant_information['field50534']
    end
  end

  private

  def get_address_from_icims(address_url)
    response = Faraday.get(address_url,
                           {},
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

  def get_attached_essay(applicant)
    return nil if applicant['field23872'].blank?
    file_location = applicant['field23872']['file'].gsub!('binary', 'text')
    Faraday.get(file_location, {}, authorization: "Basic #{Rails.application.secrets.icims_authorization_key}").body
  end

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/7383/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

  def icims_search(type:, body:)
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/7383/search/' + type
      req.body = body
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    JSON.parse(response.body)
  end

  def geocode_applicant_address(applicant)
    street_address = applicant['addresses'].each { |address| break address['addressstreet1'] if address['addresstype']['value'] == 'Home' }
    street_address.gsub!(/\s#\d+/i, '')
    geocode_address(street_address)
  end

  def geocode_address(street_address)
    sleep(1)
    response = Faraday.get('https://search.mapzen.com/v1/search/structured',
                           { api_key: Rails.application.secrets.mapzen_api_key,
                             address: street_address, locality: 'Boston', region: 'MA' })
    return nil if JSON.parse(response.body)['features'].count == 0
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return 'POINT(' + coordinates[0].to_s + ' ' + coordinates[1].to_s + ')'
  end

  def phone(applicant, phone_type)
    applicant['phones'].each do |phone|
      next if phone['phonetype'].blank?
      return phone['phonenumber'].gsub(/\D/, '') if phone['phonetype']['value'] == phone_type
    end
    return nil
  end

  def thank(phone)
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                      Rails.application.secrets.twilio_auth_token
    client.messages.create from: '6176168535', to: phone,
                           body: 'Thank you for applying to the 2017 SuccessLink Lottery.
                           We have received your application! You will receive a text and
                           email with your status in the lottery after 3/31.'
  end

  def boolean(data)
    data.to_s == 'Yes'
  end

  def missing_workflows
    local_workflows = Applicant.all.pluck(:workflow_id)
    remote_workflows = []
    current_count = 1000
    while current_count == 1000
      response = icims_search(type: 'applicantworkflows',
                              body: %Q{{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634"],"operator":"="},{"name":"applicantworkflow.id","value":["#{remote_workflows.last}"],"operator":">"}],"operator":"&"}})
      remote_workflows.push(*response['searchResults'].pluck('id'))
      current_count = response['searchResults'].pluck('id').count
    end
    remote_workflows - local_workflows
  end
end
