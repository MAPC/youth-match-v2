class AddTravelTimeScoreToPreferences < ActiveRecord::Migration[5.0]
  def change
    add_column :preferences, :travel_time_score, :float
  end
end
