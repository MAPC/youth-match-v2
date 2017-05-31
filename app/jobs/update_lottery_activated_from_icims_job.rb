class UpdateLotteryActivatedFromIcimsJob < ApplicationJob
  queue_as :default

  def perform(applicant)
    if status_is_lottery_activated?(applicant)
      Rails.logger.info 'Updating applicant to lottery activated:' + applicant.icims_id.to_s
      applicant.update(lottery_activated: true)
    else
      Rails.logger.info 'Updating applicant to not lottery activated:' + applicant.icims_id.to_s
      applicant.update(lottery_activated: false)
    end
  end

  private

  def status_is_lottery_activated?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    response['status']['id'] == 'C38354' ? true : false
  end

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/7383/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end
end
