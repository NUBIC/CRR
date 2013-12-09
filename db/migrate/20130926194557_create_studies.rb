class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.string  :irb_number
      t.string  :name
      t.string  :pi_name
      t.string  :pi_email
      t.text    :other_investigators
      t.string  :contact_name
      t.string  :contact_email
      t.string  :short_title
      t.string  :sites
      t.string  :funding_source
      t.string  :website
      t.date    :start_date
      t.date    :end_date
      t.integer :min_age
      t.integer :max_age
      t.integer :accrual_goal
      t.integer :number_of_visits
      t.text    :protocol_goals
      t.text    :inclusion_criteria
      t.text    :exclusion_criteria
      t.text    :notes
      t.string  :state
    end
  end
end
