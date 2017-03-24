class AddUserIdToApplicant < ActiveRecord::Migration[5.0]
  def change
    add_reference :applicants, :user, foreign_key: true
  end
end
