class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.string  :irb_number
      t.string  :name
      t.text    :notes
      t.string  :state
    end
  end
end
