class AddNeighborhoodToPosition < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :neighborhood, :string
  end
end
