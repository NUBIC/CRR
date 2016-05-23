class StudyInvolvementStatus < ActiveRecord::Base
  # Globals
  # VALID_STATUSES = ['none', 'enrolled', 'declined', 'no contact', 'withdrew', 'excluded', 'completed'].freeze

  # Globals
  VALID_STATUSES = [
    { name: 'completed',    description: 'Participant has completed the study. No further contact necessary.'},
    { name: 'excluded',     description: 'Participant excluded from study based on study criteria'},
    { name: 'declined',     description: 'Participant declined to participate'},
    { name: 'scheduled',    group: 'Enrolled',    description: 'Visit is currently scheduled but not yet completed.'},
    { name: 'canceled',     group: 'Enrolled',    description: 'Participant cancelled appointment.'},
    { name: 'no show',      group: 'Enrolled',    description: 'Participant failed to show for appointment.'},
    { name: 'already run',  group: 'No Contact',  description: 'Participant was already run in the study so they were not contacted.'},
    { name: 'no response',  group: 'No Contact',  description: 'Participant did not respond to researcher contact.'},
    { name: 'no attempt',   group: 'No Contact',  description: 'No contact was attempted'}
  ].freeze

  # Dependencies
  include AASM
  has_paper_trail

  # Associations
  belongs_to :study_involvement

  # Validation
  validates_inclusion_of :name, in: VALID_STATUSES.map{|s| s[:name]}

  # AASM events and transitions
  aasm column: :state do
    state :pending, initial: true
    state :approved

    event :approve do
      transitions to: :approved, from: :pending
    end
  end

  def self.valid_statuses
    VALID_STATUSES
  end
end
