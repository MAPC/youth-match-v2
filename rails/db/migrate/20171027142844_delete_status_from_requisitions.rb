class DeleteStatusFromRequisitions < ActiveRecord::Migration[5.0]
  def change
    remove_column :requisitions, :status
  end
end
