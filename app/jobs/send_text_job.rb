class SendTextJob < ApplicationJob
  queue_as :default

  def perform(to, message)
    begin
      Rails.logger.info 'Hello from SendTextWorker!'
      client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid,
                                        Rails.application.secrets.twilio_auth_token
      client.messages.create from: Rails.application.secrets.twilio_from_number, to: to,
                             body: message
    rescue Twilio::REST::RequestError => e
      Rails.logger.error 'Twilio Error: ' + e
    end
  end
end
