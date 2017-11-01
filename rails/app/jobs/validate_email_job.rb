class ValidateEmailJob < ApplicationJob
  queue_as :default

  def perform(applicant_id)
    applicant = Applicant.find(applicant_id)
    applicant.update(valid_email: valid_email(applicant.email))
  end

  private

  def valid_email(email)
    response = Faraday.get do |req|
      req.url "https://api.mailgun.net/v3/address/validate"
      req.headers['Authorization'] = 'Basic YXBpOnB1YmtleS01ZDg1MWZjOGUzYzVhZWQ4ZGVhM2M4OTRhYjA4ZWM5MQ=='
      req.params['address'] = email
      req.params['mailbox_verification'] = true
    end
    JSON.parse(response.body)['is_valid']
  end
end
