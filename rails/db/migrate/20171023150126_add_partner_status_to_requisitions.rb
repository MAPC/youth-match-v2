class AddPartnerStatusToRequisitions < ActiveRecord::Migration[5.0]
  def change
    rename_column :requisitions, :status, :partner_status
    add_column :requisitions, :applicant_status, :integer
  end
end
