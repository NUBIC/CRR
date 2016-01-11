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

  TYPES = ['Welcome', 'Express sign up'].freeze

  validates :state, inclusion: { in: STATES }, presence: true
  validates :email_type,  inclusion: { in: TYPES }, presence: true

  def editable?
    inactive?
  end
end
