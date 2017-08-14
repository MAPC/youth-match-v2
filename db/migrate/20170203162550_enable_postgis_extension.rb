class EnablePostgisExtension < ActiveRecord::Migration[5.0]
  def change
    enable_extension "postgis"
    enable_extension "plpgsql"
  end
end
