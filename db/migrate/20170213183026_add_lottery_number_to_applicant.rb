class AddLotteryNumberToApplicant < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :lottery_number, :integer
  end
end
