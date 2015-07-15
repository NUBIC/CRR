require 'active_support/concern'

module WithActiveState
  extend ActiveSupport::Concern

  ACTIVE_STATE    = 'active'.freeze
  INACTIVE_STATE  = 'inactive'.freeze
  STATES = [ACTIVE_STATE, INACTIVE_STATE].freeze

  included do
    def active?
      state == ACTIVE_STATE
    end

    def inactive?
      state == INACTIVE_STATE
    end

    def activate
      self.state = ACTIVE_STATE
    end

    def deactivate
      self.state = INACTIVE_STATE
    end

    def self.active
      where(state: ACTIVE_STATE)
    end

    def self.inactive
      where(state: INACTIVE_STATE)
    end
  end
end