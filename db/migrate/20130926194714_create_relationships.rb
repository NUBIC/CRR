class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.string  :category
      t.integer :origin_id
      t.integer :destination_id
      t.text    :notes
      t.timestamps
    end
  end
end
