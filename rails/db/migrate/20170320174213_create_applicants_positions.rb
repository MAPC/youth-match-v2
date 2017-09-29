class CreateApplicantsPositions < ActiveRecord::Migration[5.0]
  def change
    create_table :applicants_positions do |t|
      t.integer :applicant_id
      t.integer :position_id
    end
  end
end
