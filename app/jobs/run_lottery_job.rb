class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # If there are already lottery numbers assigned we should blow them up, along with all current offers.
    Applicant.where(removed_by_icims: false).order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      applicant.save!
    end
  end
end
