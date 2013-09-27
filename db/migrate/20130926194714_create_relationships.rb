class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :name
      t.integer :origin_id
      t.integer :destination_id
      t.timestamps
    end
  end
end
