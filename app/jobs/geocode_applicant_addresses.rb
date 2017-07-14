class GeocodeApplicantAddresses < ApplicationJob
  queue_as :default

  def perform
    Applicant.all.each do |applicant|
      sleep 1
      applicant.update(location: geocode_address(applicant.address))
    end
  end

  private

  def geocode_address(street_address)
    street_address.gsub!(/\s#\d+/i, '')
    response = Faraday.get('https://search.mapzen.com/v1/search/structured',
                           { api_key: Rails.application.secrets.mapzen_api_key,
                             address: street_address, locality: 'Boston', region: 'MA' })
    return nil if JSON.parse(response.body)['features'].blank?
    return nil if JSON.parse(response.body)['features'].count == 0
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return 'POINT(' + coordinates[0].to_s + ' ' + coordinates[1].to_s + ')'
  end
end
