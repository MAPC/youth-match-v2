class AddExternalIdToPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :external_id, :string
  end
end
