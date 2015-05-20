class RemoveValueFromSearchConditions < ActiveRecord::Migration
  def change
    remove_column :search_conditions, :value, :string
  end
end
