class AddUserAccountType < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :account_type, :string, null: false, default: "youth"
  end
end
