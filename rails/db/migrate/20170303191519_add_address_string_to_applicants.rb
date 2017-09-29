class AddAddressStringToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :address, :string
  end
end
