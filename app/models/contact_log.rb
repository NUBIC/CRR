# == Schema Information
#
# Table name: contact_logs
#
#  id             :integer          not null, primary key
#  participant_id :integer
#  date           :date
#  contacter      :string(255)
#  mode           :string(255)
#  notes          :text
#  created_at     :datetime
#  updated_at     :datetime
#

class ContactLog < ActiveRecord::Base
  belongs_to :participant

  MODES = ['phone','email','in_person','mail']

  validates_presence_of :participant, :mode
  validates_inclusion_of :mode, :in => MODES
end
