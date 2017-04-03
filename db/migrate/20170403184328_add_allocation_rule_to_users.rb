class AddAllocationRuleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :allocation_rule, :integer, default: 2
  end
end
