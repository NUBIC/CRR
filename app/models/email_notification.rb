class EmailNotification < ActiveRecord::Base
  # Dependencies
  include WithActiveState

  # Validations
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

  def self.suspended_participants
    where(name: 'Suspended participants').first
  end
end
