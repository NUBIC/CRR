class AddTimestampsToUserStudies < ActiveRecord::Migration
  def change
    add_column :user_studies, :created_at, :datetime
    add_column :user_studies, :updated_at, :datetime
  end
end
