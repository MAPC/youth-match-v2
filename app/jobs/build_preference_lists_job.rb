class BuildPreferenceListsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Preference.delete_all
    assign_travel_time_scores
    assign_scores
  end

  private

  def assign_travel_time_scores
    Applicant.all.each do |applicant|
      Position.all.each do |position|
        Preference.create(applicant: applicant, position: position, travel_time_score: travel_time_score(applicant, position))
      end
    end
  end

  def assign_scores
    Applicant.all.each do |applicant|
      applicant.preferences.order(travel_time_score: :asc).each_with_index do |preference, index|
        preference.score = normalize_travel_time_score(preference.applicant, index) + interest_score(preference.applicant, preference.position)
        preference.save
      end
    end
  end

  def normalize_travel_time_score(applicant, rank)
    interval = applicant.preferences.count / 10.0 # factor to divide the travel_time_score rank by
    new_score = rank / interval # here we are placing the rank on the new scale of 0-10
    new_score - 5 # and then subtract 5 to move to same scale of -5 to 5
  end

  def travel_time_score(applicant, position)
    minutes = travel_time(applicant, position).to_i / 60
    applicant.prefers_nearby? ? care(minutes) : dont_care(minutes)
  end

  def travel_time(applicant, position)
    conn = Faraday.new :request => { :params_encoder => Faraday::FlatParamsEncoder }
    response = conn.get do |req|
      req.url 'http://prep.mapc.org:8989/route'
      req.params['point'] = ["#{applicant.location.lat},#{applicant.location.long}", "#{position.location.lat},#{position.location.long}"]
      req.params['type'] = 'json'
      req.params['locale'] = 'en-US'
      req.params['vehicle'] = 'pt'
      req.params['weighting'] = 'fastest'
      req.params['elevation'] = 'false'
      req.params['pt.earliest_departure_time'] = "2017-09-01T09:00:00.000Z"
    end
    routes = JSON.parse(response.body)
    return routes['paths'][0]['time'].to_i / 1000
  rescue NoMethodError
    40.minutes.to_i
  end

  def care(minutes)
    minutes < 30 ? (0.008 * (minutes ** 2)) - (0.5833 * minutes) + 5 : -5
  end

  def dont_care(minutes)
    minutes < 40 ? (-0.25 * minutes) + 5 : -5
  end

  def interest_score(applicant, position)
    magnitude = applicant.prefers_interest? ? 5 : 3
    matches = (applicant.interests & [position.category]).any? ? 1 : -1
    return magnitude * matches
  end
end
