class Account < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_email_field = false
    c.logged_in_timeout = 10.minutes
  end

  has_many :account_participants, dependent: :destroy
  has_many :participants, through: :account_participants

  validates_uniqueness_of :email, case_sensitive: false, allow_blank: false
  validates_presence_of   :email
  validates_format_of     :email, with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i, message: 'is invalid'

  def all_participants
    participants.reject { |p| p.withdrawn? }
  end

  def active_participants
    participants.select { |p| p.active? }
  end

  def inactive_participants
    participants.select { |p| p.inactive? }
  end

  def other_participants(participant)
    active_participants.reject{ |p| p == participant}
  end

  def has_self_participant?
    account_participants.any? {|ap| ap.proxy == false && (ap.participant != nil && !ap.participant.withdrawn?)}
  end

  def child_proxy_participant
    participants.select { |p| p.active? && p.child == true && p.account_participant.proxy == true }.last
  end

  def adult_proxy_participant
    participants.select { |p| p.active? && p.child == false && p.account_participant.proxy == true }.last
  end

  def last_updated_participant
    active_participants.first
  end

  def copy_from_participant(participant)
    if participant.child_proxy?
      child_proxy_participant ? child_proxy_participant : last_updated_participant
    else
      adult_proxy_participant ? adult_proxy_participant : last_updated_participant
    end
  end

  def reset_token
    reset_perishable_token!
  end
end
