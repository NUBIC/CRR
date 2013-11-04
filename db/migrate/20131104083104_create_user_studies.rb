class CreateUserStudies < ActiveRecord::Migration
  def change
    create_table :user_studies do |t|
      t.integer :user_id
      t.integer :study_id
    end
  end
end
