class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.text    :parameters
      t.string  :connector
      t.integer :study_id
      t.date    :request_date
      t.date    :request_process_date
      t.date    :request_decline_date
    end
  end
end
