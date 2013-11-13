class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string  :title
      t.text    :description
      t.text    :state
      t.string  :code
      t.timestamps
    end
  end
end
