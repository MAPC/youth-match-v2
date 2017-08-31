class UpdateApplicantsFromIcimsJob < ApplicationJob
  include IcimsQueryable
  queue_as :default

  def perform(applicant)
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
                      address: get_address_string(applicant_information))
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
end
