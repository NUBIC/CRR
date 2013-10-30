# == Schema Information
#
# Table name: account_participants
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  participant_id :integer
#  proxy          :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  child          :boolean          default(FALSE), not null
#

class AccountParticipant < ActiveRecord::Base
  belongs_to :account
  belongs_to :participant
end
