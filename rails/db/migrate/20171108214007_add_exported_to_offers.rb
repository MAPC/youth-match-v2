class AddExportedToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :exported, :boolean, default: false
  end
end
