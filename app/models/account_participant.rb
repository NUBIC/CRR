class AccountParticipant < ApplicationRecord
  belongs_to :account
  belongs_to :participant

  accepts_nested_attributes_for :participant, allow_destroy: true
end
