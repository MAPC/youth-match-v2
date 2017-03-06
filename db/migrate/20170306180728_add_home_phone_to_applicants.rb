class AddHomePhoneToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :home_phone, :string
    rename_column :applicants, :phone, :mobile_phone
  end
end
