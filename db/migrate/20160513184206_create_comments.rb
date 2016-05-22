class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :commentable_id
      t.string :commentable_type
      t.datetime :date
      t.references :user
      t.timestamps
    end
    add_index(:comments, [:commentable_id, :commentable_type], name: 'commentable_idx')
  end
end
