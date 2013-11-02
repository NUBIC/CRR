class CreateResponseSets < ActiveRecord::Migration
  def change
    create_table :response_sets do |t|
      t.integer  :survey_id
      t.integer  :participant_id
      t.date     :effective_date
      t.datetime :completed_at
      t.timestamps
    end
  end
end
