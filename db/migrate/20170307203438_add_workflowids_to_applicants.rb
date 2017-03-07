class AddWorkflowidsToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :workflow_id, :integer
  end
end
