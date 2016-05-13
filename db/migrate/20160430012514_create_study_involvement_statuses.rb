class CreateStudyInvolvementStatuses < ActiveRecord::Migration
  def up
    create_table :study_involvement_statuses do |t|
      t.references :study_involvement
      t.string :name
      t.date  :date
      t.string :state

      t.timestamps null: false
    end

    StudyInvolvement.all.each do |study_involvement|
      new_state = case study_involvement.state
      when 'none', 'no contact'
        'no attempt'
      when 'enrolled'
        'completed'
      when 'withdrew'
        'canceled'
      else
        study_involvement.state
      end
      say study_involvement.inspect
      study_involvement.build_study_involvement_status(name: new_state, date: study_involvement.state_date)
      study_involvement.save!
    end
  end
end
