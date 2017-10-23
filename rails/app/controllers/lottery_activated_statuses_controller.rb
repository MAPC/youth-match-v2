class LotteryActivatedStatusesController < ApplicationController
  def create
    UpdateLotteryActivatedCandidatesJob.perform_later
  end
end
