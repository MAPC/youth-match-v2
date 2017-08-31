class RemoveRehireSites < ActiveRecord::Migration[5.0]
  def change
    drop_table :rehire_sites
  end
end
