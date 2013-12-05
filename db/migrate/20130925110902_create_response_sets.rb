class CreateResponseSets < ActiveRecord::Migration
  def change
    create_table :response_sets do |t|
      t.integer  :survey_id
      t.integer  :participant_id
      t.datetime :completed_at
      t.boolean  :public
      t.timestamps
    end
  end
end
