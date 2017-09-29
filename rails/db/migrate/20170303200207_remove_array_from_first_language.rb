class RemoveArrayFromFirstLanguage < ActiveRecord::Migration[5.0]
  def change
    change_column :applicants, :first_language, :string
  end
end
