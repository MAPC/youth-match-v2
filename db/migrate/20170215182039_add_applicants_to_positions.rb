class AddApplicantsToPositions < ActiveRecord::Migration[5.0]
  def change
    add_reference :positions, :applicant, index: true
    add_foreign_key :positions, :applicants
  end
end
