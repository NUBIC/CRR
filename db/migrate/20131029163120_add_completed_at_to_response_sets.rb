class AddCompletedAtToResponseSets < ActiveRecord::Migration
  def change
    add_column :response_sets, :completed_at, :datetime
  end
end
