class BuildTravelTimePreferenceJob < ApplicationJob
  queue_as :default

  def perform(applicant_id, position_id)
    applicant = Applicant.find(applicant_id)
    position = Position.find(position_id)
    assign_travel_time_score(applicant, position)
  end

  private

  def assign_travel_time_score(applicant, position)
    Preference.create(applicant: applicant, position: position, travel_time_score: travel_time_score(applicant, position))
  end

  def travel_time_score(applicant, position)
    minutes = travel_time(applicant, position).to_i / 60
    applicant.prefers_nearby? ? care(minutes) : dont_care(minutes)
  end

  def travel_time(applicant, position)
    conn = Faraday.new :request => { :params_encoder => Faraday::FlatParamsEncoder }
    response = conn.get do |req|
      req.url 'http://127.0.0.1:8989/route'
      req.params['point'] = ["#{applicant.location.lat},#{applicant.location.lon}", "#{position.location.lat},#{position.location.lon}"]
      req.params['type'] = 'json'
      req.params['locale'] = 'en-US'
      req.params['vehicle'] = 'pt' # applicant.mode
      req.params['weighting'] = 'fastest'
      req.params['elevation'] = 'false'
      req.params['pt.earliest_departure_time'] = '2017-09-01T09:00:00.000Z'
      req.options.timeout = 300
      req.options.open_timeout = 300
    end
    unless response.success?
      Rails.logger.error 'Travel Time Request Status: ' + response.status.to_s + ' Body: ' + response.body
    end
    routes = JSON.parse(response.body)
    routes['paths'][0]['time'].to_i / 1000
  rescue => error
    Rails.logger.error "An error of type #{error.class} happened, message is #{error.message}"
    40.minutes.to_i
  end

  def care(minutes)
    minutes < 30 ? (0.008 * (minutes ** 2)) - (0.5833 * minutes) + 5 : -5
  end

  def dont_care(minutes)
    minutes < 40 ? (-0.25 * minutes) + 5 : -5
  end
end
