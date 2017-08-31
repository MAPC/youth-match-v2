class CreateOutgoingMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :outgoing_messages do |t|
      t.text :to, array: true, default: []
      t.string :body

      t.timestamps
    end
  end
end
