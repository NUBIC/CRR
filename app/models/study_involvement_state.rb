class StudyInvolvementState < ActiveRecord::Base
  # Globals
  # VALID_STATES = ['none', 'enrolled', 'declined', 'no contact', 'withdrew', 'excluded', 'completed'].freeze

  # Globals
  VALID_STATES = [
    { name: 'scheduled',    description: 'Visit is currently scheduled but not yet completed.'},
    { name: 'canceled',     description: 'Participant cancelled appointment.'},
    { name: 'no show',      description: 'Participant failed to show for appointment.'},
    { name: 'already run',  description: 'Participant was already run in the study so they were not contacted.'},
    { name: 'no response',  description: 'Participant did not respond to researcher contact.'},
    { name: 'no attempt',   description: 'No contact was attempted'},
    { name: 'completed',    description: 'Participant has completed the study. No further contact necessary.'},
    { name: 'excluded',     description: 'Participant excluded from study based on study criteria'},
    { name: 'declined',     description: 'Participant declined to participate'}
  ].freeze

  # Dependencies
  include AASM
  has_paper_trail

  # Associations
  belongs_to :study_involvement

  # Validation
  validates_inclusion_of :name, in: VALID_STATES.map{|s| s[:name]}

  # AASM events and transitions
  aasm column: :status do
    state :pending, initial: true
    state :approved

    event :approved do
      transitions to: :approved, from: :pending
    end
  end
end
