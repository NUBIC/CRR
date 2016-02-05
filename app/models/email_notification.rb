# == Schema Information
#
# Table name: email_notifications
#
#  id         :integer          not null, primary key
#  state      :string(255)
#  content    :text
#  email_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class EmailNotification < ActiveRecord::Base
  include WithActiveState

  WELCOME_PARTICIPANT = 'Welcome participant'
  WELCOME_RESEARCHER  = 'Welcome researcher'
  EXPRESS_SIGN_UP     = 'Express sign up'
  BATCH_RELEASED      = 'Batch released'
  RELEASE_EXPIRING    = 'Release expiring'
  RELEASE_EXPIRED     = 'Release expired'

  TYPES = [WELCOME_PARTICIPANT, WELCOME_RESEARCHER, EXPRESS_SIGN_UP, BATCH_RELEASED, RELEASE_EXPIRING, RELEASE_EXPIRED].freeze

  validates :state, inclusion: { in: STATES }, presence: true
  validates :email_type,  inclusion: { in: TYPES }, presence: true

  def editable?
    inactive?
  end
end
