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
#

require 'spec_helper'

describe AccountParticipants do
  pending "add some examples to (or delete) #{__FILE__}"
end
