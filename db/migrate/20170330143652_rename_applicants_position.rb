class RenameApplicantsPosition < ActiveRecord::Migration[5.0]
  def change
    rename_table :applicants_positions, :requisitions
  end
end
