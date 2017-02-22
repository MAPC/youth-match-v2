class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Applicant.order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      applicant.save!
    end
  end
end
