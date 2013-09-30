class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.text    :parameters
      t.string  :connector
      t.integer :study_id
      t.string  :state
      t.date    :request_date
      t.date    :process_date
      t.date    :decline_date
    end
  end
end
