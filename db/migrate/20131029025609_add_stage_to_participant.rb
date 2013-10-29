class AddStageToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :stage, :string
  end
end
