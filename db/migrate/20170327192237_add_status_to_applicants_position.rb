class AddStatusToApplicantsPosition < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants_positions, :status, :integer
  end
end
