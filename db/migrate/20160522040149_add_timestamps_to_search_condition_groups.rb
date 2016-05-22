class AddTimestampsToSearchConditionGroups < ActiveRecord::Migration
  def change
    add_column :search_condition_groups, :created_at, :datetime
    add_column :search_condition_groups, :updated_at, :datetime
  end
end
