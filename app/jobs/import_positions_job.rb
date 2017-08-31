class ImportPositionsJob < ApplicationJob
  include IcimsQueryable
  queue_as :default

  def perform(icims_id)
    job = icims_get(object: 'jobs', id: icims_id, fields: 'overview,responsibilities,qualifications,positiontype,numberofpositions,jobtitle,joblocation,field51224')
    job_address = get_address_from_icims(job['joblocation']['address'])
    position = Position.new(icims_id: icims_id,
                            title: job['jobtitle'],
                            category: job['field51224'],
                            duties_responsbilities: job['responsibilities'],
                            address: job_address['addressstreet1'],
                            site_name: job['joblocation']['value'],
                            location: geocode_address(job_address['addressstreet1']))
    position.save!
  end

  private

  def get_address_from_icims(address_url)
    response = Faraday.get(address_url,
                           {},
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

  def geocode_address(street_address)
    response = Faraday.get('https://search.mapzen.com/v1/search/structured',
                           { api_key: Rails.application.secrets.mapzen_api_key,
                             address: street_address, locality: 'Boston', region: 'MA' })
    return nil if JSON.parse(response.body)['features'].count == 0
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return 'POINT(' + coordinates[0].to_s + ' ' + coordinates[1].to_s + ')'
  end
end
