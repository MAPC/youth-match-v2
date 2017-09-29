class AddFieldsToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :receive_text_messages, :boolean
    add_column :applicants, :phone, :string
    add_column :applicants, :guardian_name, :string
    add_column :applicants, :guardian_phone, :string
    add_column :applicants, :guardian_email, :string
  end
end
