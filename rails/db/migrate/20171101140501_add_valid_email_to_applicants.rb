class AddValidEmailToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, 'valid_email', :boolean
  end
end
