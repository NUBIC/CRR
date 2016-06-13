class AddExtendedReleaseToStudyInvolvements < ActiveRecord::Migration
  def change
    add_column :study_involvements, :extended_release, :boolean, default: false

    StudyInvolvement.all.each do |study_involvement|
      study_involvement.extended_release = false if study_involvement.extended_release.blank?
    end
  end
end
