class CreateStudyInvolvements < ActiveRecord::Migration
  def change
    create_table :study_involvements do |t|
      t.integer :study_id
      t.integer :participant_id
      t.date    :start_date
      t.date    :end_date
      t.text    :notes
      t.timestamps
    end
  end
end
