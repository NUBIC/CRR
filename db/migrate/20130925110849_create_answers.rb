class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :question_id
      t.text    :text
      t.text    :help_text
      t.integer :display_order
      t.string  :reference
      t.integer :weight
      t.timestamps
    end
  end
end
