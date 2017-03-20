class LotteryRunsController < ApplicationController
  def create
    RunLotteryJob.perform_now
    render body: 'Applicants have been assigned lottery numbers'
  end
end
