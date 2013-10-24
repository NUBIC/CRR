class CreateAccountParticipants < ActiveRecord::Migration
  def change
    create_table :account_participants do |t|
      t.references :account, index: true
      t.references :participant, index: true
      t.boolean :proxy, :default => false, :null => false
      t.timestamps
    end
  end
end
