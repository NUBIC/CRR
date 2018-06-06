class ContactLog < ApplicationRecord
  # Globals
  MODES = ['phone', 'email', 'in_person', 'mail'].freeze

  # Associations
  belongs_to :participant

  # Validations
  validates_presence_of :participant, :mode
  validates_inclusion_of :mode, in: MODES
end
