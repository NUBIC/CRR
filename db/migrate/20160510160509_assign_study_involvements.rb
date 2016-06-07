class AssignStudyInvolvements < ActiveRecord::Migration
  def change
    SearchParticipant.where(released: true).each do |search_participant|
      participant = search_participant.participant
      search      = search_participant.search
      study_involvements = participant.study_involvements.where(study_id: search.study.id)
      if study_involvements.size > 1
        raise 'oops'
      elsif study_involvements.empty?
        study_involvement = participant.study_involvements.create!(start_date: search.start_date, end_date: search.end_date, warning_date: search.warning_date, study_id: search.study.id)
      else
        study_involvement = study_involvements.first
      end
      search_participant.study_involvement = study_involvement
      search_participant.save!
    end
  end
end
