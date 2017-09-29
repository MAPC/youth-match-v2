class AddNeighborhoodToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :neighborhood, :string
  end
end
