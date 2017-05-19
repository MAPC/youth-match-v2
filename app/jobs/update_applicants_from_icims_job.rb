class UpdateApplicantsFromIcimsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.all.each do |applicant|
      Rails.logger.info "Updating applicant #{applicant.first_name} #{applicant.icims_id}"
      applicant_information = icims_get(object: 'people',
                                        fields: 'firstname,middlename,lastname,email,phones,field50527,addresses,field50534,source,sourcename,field51088,field51089,field51090,field23807,field51062,field23809,field23810,field23849,field23850,field23851,field23852,field29895,field36999,field51069,field51122,field51123,field51124,field51125,field51027,field51034,field51053,field51054,field51055,field23872,field23873',
                                        id: applicant.icims_id)
      applicant.update( first_name: applicant_information['firstname'],
                        email: applicant_information['email'],
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
                        location: geocode_applicant_address(applicant_information),
                        address: get_address_string(applicant_information))
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
