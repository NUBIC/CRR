class SearchParticipant < ActiveRecord::Base
  # Associations
  belongs_to :search
  belongs_to :participant
  has_one :search_participant_study_involvement
  has_one :study_involvement, through: :search_participant_study_involvement, dependent: :destroy

  accepts_nested_attributes_for :search_participant_study_involvement
  accepts_nested_attributes_for :study_involvement

  # Validations
  validates_presence_of :search, :participant

  # Scopes
  scope :released, -> { where(released: true)}
  scope :returned, -> { joins(study_involvement: :study_involvement_status).where(study_involvement_statuses: { state: ['pending', 'approved']})}
end
