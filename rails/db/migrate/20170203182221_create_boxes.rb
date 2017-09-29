class CreateBoxes < ActiveRecord::Migration[5.0]
  def change
    create_table :boxes do |t|
      t.multi_polygon :geom, srid: 4326
      t.integer :g250m_id
      t.string :municipal
      t.integer :muni_id
    end
  end
end
