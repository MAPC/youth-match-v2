class CreatePicks < ActiveRecord::Migration[5.0]
  def change
    create_table :picks do |t|
      t.references :applicant, foreign_key: true
      t.references :position, foreign_key: true

      t.timestamps
    end
  end
end
