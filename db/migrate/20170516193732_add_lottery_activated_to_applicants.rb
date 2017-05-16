class AddLotteryActivatedToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :lottery_activated, :boolean
  end
end
