class CreateStudyInvolvementStates < ActiveRecord::Migration
  def change
    create_table :study_involvement_states do |t|
      t.references :study_involvement
      t.string :name
      t.date  :date
      t.string :status

      t.timestamps null: false
    end

    StudyInvolvement.all.each do |study_involvement|
      new_state = case study_involvement.state
      when 'none', 'no contact'
        'no attempt'
      when 'enrolled'
        'completed'
      when 'withdrew'
        'cancelled'
      else
        study_involvement.state
      end
      study_involvement.build_study_involvement_state(name: new_state, date: study_involvement.state_date)
      study_involvement.save!
    end
  end
end
