class AddRemovedByIcimsToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :removed_by_icims, :boolean, default: false
  end
end
