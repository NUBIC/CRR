class AddTimestampsToStudies < ActiveRecord::Migration
  def change
    add_column :studies, :created_at, :datetime
    add_column :studies, :updated_at, :datetime
  end
end
