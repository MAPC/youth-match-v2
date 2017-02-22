class CreatePreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :preferences do |t|
      t.references :applicant, foreign_key: true
      t.references :position, foreign_key: true
      t.float :score

      t.timestamps
    end
  end
end
