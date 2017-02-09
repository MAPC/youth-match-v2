class CreateApplicants < ActiveRecord::Migration[5.0]
  def change
    create_table :applicants do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :icims_id
      t.string :interests, array: true
      t.boolean :prefers_nearby
      t.boolean :has_transit_pass
      t.integer :grid_id
      t.st_point :location, srid: 4326, geographic: true

      t.timestamps
    end
  end
end
