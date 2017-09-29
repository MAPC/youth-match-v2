class AddIcimsIdToRehireSites < ActiveRecord::Migration[5.0]
  def change
    add_column :rehire_sites, :icims_id, :integer
  end
end
