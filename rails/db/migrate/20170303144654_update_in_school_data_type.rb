class UpdateInSchoolDataType < ActiveRecord::Migration[5.0]
  def change
    change_column :applicants, :in_school, 'boolean USING CAST(in_school AS boolean)'
  end
end
