class ImportApplicantsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    response = icims_search(type: 'applicantworkflows',
                            body: '{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634 "],"operator":"="},{"name":"applicantworkflow.id","value":["57350"],"operator":">"}],"operator":"&"}')
    workflows = response['searchResults'].pluck('id') - Applicant.all.pluck(:workflow_id)
    workflows.each do |workflow_id|
      workflow = icims_get(object: 'applicantworkflows', id: workflow_id)
      applicant_id = workflow['associatedprofile']['id']
      applicant_information = icims_get(object: 'people',
                                        fields: 'firstname,middlename,lastname,email,phones,field50527,addresses,field50534,source,sourcename,field51088,field51089,field51090,field23807,field51062,field23809,field23810,field23849,field23850,field23851,field23852,field29895,field36999,field51069,field51122,field51123,field51124,field51125,field51027,field51034,field51053,field51054,field51055,field23872,field23873',
                                        id: applicant_id)
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
                                address: get_address_string(applicant_information),
                                workflow_id: workflow_id)
      applicant.save!
    end
  end

  private

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
    street_address.gsub!(/\s#\d+/i, '')
    geocode_address(street_address)
  end

  def geocode_address(street_address)
    response = Faraday.get('https://search.mapzen.com/v1/search/structured',
                           { api_key: Rails.application.secrets.mapzen_api_key,
                             address: street_address, locality: 'Boston', region: 'MA' })
    return nil if JSON.parse(response.body)['features'].count == 0
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return 'POINT(' + coordinates[0].to_s + ' ' + coordinates[1].to_s + ')'
  end

  def phone(applicant, phone_type)
    return nil if applicant['phones'].blank?
    applicant['phones'].each do |phone|
      next if phone['phonetype'].blank?
      return phone['phonenumber'].gsub(/\D/, '') if phone['phonetype']['value'] == phone_type
    end
    return nil
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
end
