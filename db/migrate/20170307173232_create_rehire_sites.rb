class CreateRehireSites < ActiveRecord::Migration[5.0]
  def change
    create_table :rehire_sites do |t|
      t.string :site_name
      t.string :person_name
      t.boolean :should_rehire

      t.timestamps
    end
  end
end
