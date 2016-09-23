class AddUniqueIndexOnNetidToUsers < ActiveRecord::Migration
  def change
    add_index :users, :netid, unique: true
  end
end
