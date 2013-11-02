class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.string  :irb_number
      t.string  :name
      t.date    :active_on
      t.date    :inactive_on
    end
  end
end
