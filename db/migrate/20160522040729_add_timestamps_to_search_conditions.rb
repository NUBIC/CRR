class AddTimestampsToSearchConditions < ActiveRecord::Migration
  def change
    add_column :search_conditions, :created_at, :datetime
    add_column :search_conditions, :updated_at, :datetime
  end
end
