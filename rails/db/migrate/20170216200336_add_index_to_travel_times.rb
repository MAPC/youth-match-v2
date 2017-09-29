class AddIndexToTravelTimes < ActiveRecord::Migration[5.0]
  def change
    add_index :travel_times, :input_id
    add_index :travel_times, :target_id
  end
end
