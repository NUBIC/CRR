class SearchParticipant < ActiveRecord::Base
  # Associations
  belongs_to :search
  belongs_to :participant

  # Validations
  validates_presence_of :search, :participant

  # Scopes
  scope :release, -> { where(released: true)}
end
