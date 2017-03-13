class CreateOffers < ActiveRecord::Migration[5.0]
  def change
    create_table :offers do |t|
      t.references :applicant
      t.references :position
      t.integer :accepted

      t.timestamps
    end
  end
end
