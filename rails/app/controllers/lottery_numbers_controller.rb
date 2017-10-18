class LotteryNumbersController < ApplicationController
  def create
    RunLotteryJob.perform_later
    render body: 'Lottery numbers will be assigned for all applicants.'
  end
end
