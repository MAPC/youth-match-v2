class AddAttachedFileTextToApplicants < ActiveRecord::Migration[5.0]
  def change
    add_column :applicants, :participant_essay_attached_file, :text
  end
end
