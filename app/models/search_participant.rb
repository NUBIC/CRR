# == Schema Information
#
# Table name: search_participants
#
#  id             :integer          not null, primary key
#  search_id      :integer
#  participant_id :integer
#  released       :boolean          default(FALSE), not null
#

class SearchParticipant < ActiveRecord::Base
  belongs_to :search
  belongs_to :participant

  validates_presence_of :search, :participant
  scope :release, -> { where(released: true)}
end
