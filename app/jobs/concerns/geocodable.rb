module Geocodable
  extend ActiveSupport::Concern

  private

  def geocode_address(street_address:, locality: 'Boston', region: 'MA')
    street_address.gsub!(/\s#\d+/i, '')
    response = Faraday.get('https://search.mapzen.com/v1/search/structured',
                           { api_key: Rails.application.secrets.mapzen_api_key,
                             address: street_address, locality: locality, region: region })
    raise ResponseError, "MapZen Geocoder Error #{response.status}: #{response.body}" unless response.success?
    raise NoFeaturesFoundError if JSON.parse(response.body)['features'].blank?
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return 'POINT(' + coordinates[0].to_s + ' ' + coordinates[1].to_s + ')'
  end

  # methods defined here are going to extend the class, not the instance of it
  module ClassMethods
    # def tag_limit(value)
    #   self.tag_limit_value = value
    # end
  end
end
