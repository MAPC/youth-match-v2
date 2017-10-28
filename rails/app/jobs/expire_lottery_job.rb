class ExpireLotteryJob < ApplicationJob
  queue_as :expire_lottery

  def perform
    Offer.where(accepted: 'offer_sent').each do |offer|
      offer.update(accepted: 'expired')
    end
  end
end
