class RemoveTravelTimeTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :travel_times
    drop_table :boxes
  end
end
