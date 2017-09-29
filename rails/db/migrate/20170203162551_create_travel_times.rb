class CreateTravelTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_times do |t|
      t.integer :input_id
      t.integer :target_id
      t.integer :g250m_id_origin
      t.integer :g250m_id_destination
      t.numeric :distance
      t.decimal :x_origin, precision: 15, scale: 12
      t.decimal :y_origin, precision: 15, scale: 12
      t.decimal :x_destination, precision: 15, scale: 12
      t.decimal :y_destination, precision: 15, scale: 12
      t.string :travel_mode
      t.integer :time
      t.integer :pair_id
    end
  end
end
