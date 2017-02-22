class CreatePositions < ActiveRecord::Migration[5.0]
  def change
    create_table :positions do |t|
      t.integer :icims_id
      t.string :title
      t.string :category
      t.integer :grid_id
      t.st_point :location, srid: 4326, geographic: true

      t.timestamps
    end
  end
end
