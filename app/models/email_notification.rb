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

  validates :state, inclusion: { in: STATES }, presence: true
  validates :name,  presence: true, uniqueness: true

  def editable?
    inactive?
  end

  def self.welcome_participant
    where(name: 'Welcome participant').first
  end

  def self.welcome_researcher
    where(name: 'Welcome researcher').first
  end

  def self.express_sign_up
    where(name: 'Express sign up').first
  end

  def self.batch_released
    where(name: 'Batch released').first
  end

  def self.release_expiring
    where(name: 'Release expiring').first
  end

  def self.release_expired
    where(name: 'Release expired').first
  end
end
