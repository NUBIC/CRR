class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :section_id
      t.text    :text 
      t.string  :code
      t.boolean :is_mandatory
      t.string  :response_type
      t.integer :display_order
      t.text    :help_text
      t.timestamps
    end
  end
end
