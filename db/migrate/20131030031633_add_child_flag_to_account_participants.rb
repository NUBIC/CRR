class AddChildFlagToAccountParticipants < ActiveRecord::Migration
  def change
    add_column :account_participants, :child, :boolean, :default => false, :null => false
  end
end
