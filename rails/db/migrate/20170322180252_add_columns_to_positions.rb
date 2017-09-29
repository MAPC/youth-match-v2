class AddColumnsToPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :duties_responsbilities, :text
    add_column :positions, :ideal_candidate, :text
    add_column :positions, :open_positions, :integer
    add_column :positions, :site_name, :string
    add_column :positions, :external_application_url, :string
    add_column :positions, :primary_contact_person, :string
    add_column :positions, :primary_contact_person_title, :string
    add_column :positions, :primary_contact_person_phone, :string
    add_column :positions, :site_phone, :string
  end
end
