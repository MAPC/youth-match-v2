require 'csv'

namespace :import do
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
      a.open_positions = 5
      a.save
    end
  end

  desc 'Import applicants from ICIMS'
  task applicants_from_icims: :environment do
    response = icims_search(type: 'applicantworkflows',
                            body: '{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634"],"operator":"="}],"operator":"&"}')
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
      ImportPositionsJob.perform_now(job_id)
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
      a.external_id = row['external_id']
      a.save
    end
  end

  desc 'Update allocation rules for partners'
  task allocation_data: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'exempt_partners_2017_100_percent.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    Rails.logger.info '======Updating Partner Allocation Rules======'
    csv.each_with_index do |row|
      user = User.find_by_email(row['Primary Contact Email'].downcase)
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

  desc 'Check for workflows removed from prod'
  task check_removed_workflows: :environment do
    local_workflows = Applicant.all.pluck(:workflow_id)
    remote_workflows = []
    current_count = 1000
    while current_count == 1000
      response = icims_search(type: 'applicantworkflows',
                              body: %Q{{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634"],"operator":"="},{"name":"applicantworkflow.id","value":["#{remote_workflows.last}"],"operator":">"}],"operator":"&"}})
      remote_workflows.push(*response['searchResults'].pluck('id'))
      current_count = response['searchResults'].pluck('id').count
    end
    puts local_workflows - remote_workflows
  end

  desc 'Delete disqualified applications'
  task delete_disqualified_applicants: :environment do
    local_workflows = Applicant.all.pluck(:workflow_id)
    remote_workflows = []
    current_count = 1000
    while current_count == 1000
      response = icims_search(type: 'applicantworkflows',
                              body: %Q{{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634"],"operator":"="},{"name":"applicantworkflow.id","value":["#{remote_workflows.last}"],"operator":">"}],"operator":"&"}})
      remote_workflows.push(*response['searchResults'].pluck('id'))
      current_count = response['searchResults'].pluck('id').count
    end
    applicants_to_remove = local_workflows - remote_workflows
    applicants_to_remove.each do |workflow_id|
      Applicant.find_by_workflow_id(workflow_id).try(:destroy)
    end
  end

  desc 'Check merge records'
  task update_merge_records: :environment do
    applicants = Applicant.where(email: nil)
    applicants.each do |applicant|
      merged_id = applicant.first_name.match(/Merged with (\d+)/).captures[0]
      puts 'Applicant not imported: ' + merged_id.to_s + 'Old ID: ' + applicant.icims_id.to_s
      applicant_information = icims_get(object: 'people',
                                        fields: 'firstname,middlename,lastname,email,phones,field50527,addresses,field50534,source,sourcename,field51088,field51089,field51090,field23807,field51062,field23809,field23810,field23849,field23850,field23851,field23852,field29895,field36999,field51069,field51122,field51123,field51124,field51125,field51027,field51034,field51053,field51054,field51055,field23872,field23873',
                                        id: merged_id)
      applicant.update(first_name: applicant_information['firstname'],
                        last_name: applicant_information['lastname'],
                        email: applicant_information['email'],
                        icims_id: merged_id,
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
                        address: get_address_string(applicant_information),
                        workflow_id: applicant.workflow_id,
                        neighborhood: applicant_information['field50534']['value'])
    end
  end

  desc 'Update applicant information from ICIMS'
  task refresh_applicant_data: :environment do
    Applicant.all.each do |applicant|
      UpdateApplicantsFromIcimsJob.perform_later(applicant)
    end
  end

  desc 'Update position information from ICIMS'
  task refresh_position_data: :environment do
    Position.all.each do |position|
      UpdateOpenPositionsFromIcimsJob.perform_later(position)
    end
  end

  desc 'Merge merged records'
  task fix_merged_records: :environment do
    Applicant.where(email: nil).each do |applicant|
      merge_record(applicant.id, merged_record_icims_id(applicant))
    end
  end

  desc 'Set exempt requisitions to zero openings'
  task zero_exempt_reqs: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'reqs_exempt.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each do |row|
      position = Position.find_by_icims_id(row['ID'])
      position.update(open_positions: 0) if position
    end
  end

  desc 'Geocode Applicant Addresses'
  task geocode_applicants: :environment do
    Applicant.where(location: nil).each do |applicant|
      applicant.location = geocode_address(applicant.address)
      applicant.save
      sleep 1
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
    response = Faraday.get("https://api.icims.com/customers/6405/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

  def icims_search(type:, body:)
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/6405/search/' + type
      req.body = body
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 60
      req.options.open_timeout = 60
    end
    JSON.parse(response.body)
  end

  def geocode_applicant_address(applicant)
    return nil if applicant['addresses'].blank?
    applicant['addresses'].each do |address|
      return nil if address.blank?
      return address['addressstreet1'] if address['addresstype'].blank?
    end
    street_address = applicant['addresses'].each { |address| break address['addressstreet1'] if address['addresstype']['value'] == 'Home' }
    return nil if street_address.is_a?(Array)
    street_address.gsub!(/\s#\d+/i, '')
    geocode_address(street_address)
  end

  def geocode_address(street_address)
    response = Faraday.get('https://search.mapzen.com/v1/search/structured',
                           { api_key: Rails.application.secrets.mapzen_api_key,
                             address: street_address, locality: 'Boston', region: 'MA' })
    return nil if JSON.parse(response.body)['features'].blank?
    return nil if JSON.parse(response.body)['features'].count == 0
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return 'POINT(' + coordinates[0].to_s + ' ' + coordinates[1].to_s + ')'
  end

  def phone(applicant, phone_type)
    return nil if applicant['phones'].blank?
    applicant['phones'].each do |phone|
      next if phone['phonetype'].blank?
      next if phone['phonenumber'].blank?
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

  def get_address_string(applicant)
    return nil if applicant['addresses'].blank?
    applicant['addresses'].each do |address|
      return nil if address.blank?
      return address['addressstreet1'] if address['addresstype'].blank?
    end
    applicant['addresses'].each { |address| break address['addressstreet1'] if address['addresstype']['value'] == 'Home' }
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

  def merged_record_icims_id(applicant_information)
    if applicant_information.first_name.match?(/Merged with (\d+)/)
      applicant_information.first_name.match(/Merged with (\d+)/).captures[0]
    end
    return nil
  end

  def merge_record(old_record_id, merged_record_icims_id)
    # move the associations from the old record to the new record. Run this after importing latest data.
    old_applicant_record = Applicant.find(old_record_id)
    existing_applicant = Applicant.find_by_icims_id(merged_record_icims_id)
    if existing_applicant
      Pick.find_by(applicant: old_applicant_record).update(applicant: existing_applicant)
      Requisiton.where(applicant_id: old_applicant_record.id).each do |requisition|
        requisition.update(applicant_id: existing_applicant.id)
      end
      Offer.where(applicant_id: old_applicant_record.id).each do |offer|
        offer.update(applicant_id: existing_applicant.id)
      end
    end
    old_applicant_record.destroy
  end
end
