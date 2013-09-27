class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :netid
      t.boolean :admin
      t.boolean :researcher
      t.string  :first_name
      t.string  :last_name
      t.timestamps
    end
  end
end
