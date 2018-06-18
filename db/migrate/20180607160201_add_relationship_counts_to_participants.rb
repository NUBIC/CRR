class AddRelationshipCountsToParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :participants, :origin_relationships_count, :integer, default: 0
    add_column :participants, :destination_relationships_count, :integer, default: 0

    Participant.reset_column_information
    Participant.pluck(:id).map{|p_id| Participant.reset_counters(p_id, :origin_relationships, :destination_relationships)}
  end
end
