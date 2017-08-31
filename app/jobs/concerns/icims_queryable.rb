module IcimsQueryable
  extend ActiveSupport::Concern

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

  # methods defined here are going to extend the class, not the instance of it
  module ClassMethods
    # def tag_limit(value)
    #   self.tag_limit_value = value
    # end
  end
end
