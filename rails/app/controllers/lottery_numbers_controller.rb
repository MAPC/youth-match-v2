class LotteryNumbersController < ApplicationController
  def create
    RunLotteryJob.perform_later
  end
end
