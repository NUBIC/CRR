class RemoveStateColumnsFromStudyInvolvements < ActiveRecord::Migration
  def change
    remove_column :study_involvements, :state, :string
    remove_column :study_involvements, :state_date, :date
  end
end
