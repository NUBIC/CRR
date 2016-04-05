class AccountParticipant < ActiveRecord::Base
  belongs_to :account
  belongs_to :participant
end
