class AddAddressToPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :address, :string
  end
end
