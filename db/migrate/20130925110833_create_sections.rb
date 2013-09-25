class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :survey_id
      t.text    :title
      t.integer :display_order
    end
  end
end
