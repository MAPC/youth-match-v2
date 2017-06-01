class UpdateOpenPositionsFromIcimsJob < ApplicationJob
  queue_as :default

  def perform(position)
    position_information = icims_get(object: 'jobs',
                                      fields: 'numberofpositions',
                                      id: position.icims_id)
    # get the number of folks in the four bin/statuses that are excluded:
    # Selected by Site C2028
    # Onboarding C23504
    # Documents Ready C51324
    # OHR Compliance C23505
    # Lottery Placement Accepted: C36951
    response = icims_search(type: 'applicantworkflows',
                            body: %Q{{"filters":[{"name":"applicantworkflow.status","value":["C2028","C23504","C51324","C23505","C36951"],"operator":"="},{"name":"applicantworkflow.job.id","value":["#{position.icims_id}"],"operator":"="}],"operator":"&"}})
    open_position_count = position_information['numberofpositions'].to_i - response['searchResults'].pluck('id').count
    open_position_count = 0 if open_position_count < 0
    position.update(open_positions: open_position_count)
  end

  private

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

  def icims_search(type:, body:)
    response = Faraday.post do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/search/" + type
      req.body = body
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    JSON.parse(response.body)
  end
end
