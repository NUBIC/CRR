class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string  :title
      t.text    :description
      t.text    :state
      t.string  :code
      t.boolean :multiple_section
      t.timestamps
    end
  end
end
