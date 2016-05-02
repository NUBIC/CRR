class RemoveStateColumnsFromStudyInvolvements < ActiveRecord::Migration
  def change
    remove_column :study_involvements, :state
    remove_column :study_involvements, :state_date
  end
end
