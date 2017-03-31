class CreateSites < ActiveRecord::Migration[5.0]
  def change
    create_table :sites do |t|
      t.references :user
      t.references :position

      t.timestamps
    end
  end
end
