class AddStatusToPicks < ActiveRecord::Migration[5.0]
  def change
    add_column :picks, :status, :integer
  end
end
