class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.integer :study_id
      t.string  :state
      t.date    :request_date
      t.date    :process_date
      t.date    :decline_date
    end
    create_table :search_condition_groups do |t|
      t.integer :search_id
      t.integer :search_condition_group_id
      t.string  :operator
    end
    create_table :search_conditions do |t|
      t.integer :search_condition_group_id
      t.string  :operator
      t.integer :question_id
      t.string :value
    end
  end
end
