class AddTier2ToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :tier_2, :boolean, default: false, null: false
  end
end
