class AddContactLog < ActiveRecord::Migration
  def change
    create_table :contact_logs do |t|
      t.integer :participant_id
      t.date    :date
      t.string  :contacter
      t.string  :mode
      t.text    :notes
      t.timestamps
    end
  end
end
