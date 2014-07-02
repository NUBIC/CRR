class RemoveMiddleNameFromParticipants < ActiveRecord::Migration
  def change
    remove_column :participants, :middle_name
  end
end
