class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.text :parameters
      t.string :connector
      t.integer :study_id
    end
  end
end
