class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :netid
      t.boolean :admin
      t.boolean :researcher
    end
  end
end
