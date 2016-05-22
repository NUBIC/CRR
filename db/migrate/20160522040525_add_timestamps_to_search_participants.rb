class AddTimestampsToSearchParticipants < ActiveRecord::Migration
  def change
    add_column :search_participants, :created_at, :datetime
    add_column :search_participants, :updated_at, :datetime
  end
end
