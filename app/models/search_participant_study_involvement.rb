class SearchParticipantStudyInvolvement < ActiveRecord::Base
  belongs_to :search_participant
  belongs_to :study_involvement

  accepts_nested_attributes_for :study_involvement
end
