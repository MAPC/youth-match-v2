class UpdateApplicantInterestsField < ActiveRecord::Migration[5.0]
  def change
    change_column :applicants, :interests, :string, array: true
  end
end
