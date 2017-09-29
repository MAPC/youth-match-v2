class AddPrimaryContactEmailToPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :primary_contact_person_email, :string
  end
end
