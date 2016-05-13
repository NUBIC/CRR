class CreateSearchParticipantStudyInvolvements < ActiveRecord::Migration
  def change
    create_table :search_participant_study_involvements do |t|
      t.references :study_involvement
      t.references :search_participant

      t.timestamps null: false
    end
  end
end
