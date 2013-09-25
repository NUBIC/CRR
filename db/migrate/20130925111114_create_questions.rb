class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :survey_id
      t.integer :section_id
      t.text    :text 
      t.string  :reference
      t.boolean :is_mandatory
      t.string  :response_type
      t.timestamps
    end
  end
end
