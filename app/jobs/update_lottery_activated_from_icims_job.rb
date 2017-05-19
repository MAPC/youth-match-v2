class UpdateLotteryActivatedFromIcimsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.all.each do |applicant|
      if status_is_lottery_activated?(applicant)
        applicant.update(lottery_activated: true)
      else
        applicant.update(lottery_activated: false)
      end
    end
  end

  private

  def status_is_lottery_activated?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    response['status']['id'] == 'C38354' ? true : false
  end
end
