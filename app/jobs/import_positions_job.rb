class ImportPositionsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    response = icims_search(type: 'jobs', body: '{"filters":[{"name":"job.jobtitle","value":["successlink"],"operator":"="}]}')
    jobs = response['searchResults'].pluck('id') - Position.all.pluck(:icims_id)
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

  private

  def icims_search(type:, body:)
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/7383/search/' + type
      req.body = body
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    JSON.parse(response.body)
  end

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/7383/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

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
