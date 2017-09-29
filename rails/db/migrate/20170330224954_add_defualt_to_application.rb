class AddDefualtToApplication < ActiveRecord::Migration[5.0]
  def change
    change_column :requisitions, :status, :integer, default: 0
  end
end
