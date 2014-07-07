# == Schema Information
#
# Table name: accounts
#
#  id                :integer          not null, primary key
#  email             :string(255)
#  crypted_password  :string(255)
#  password_salt     :string(255)
#  persistence_token :string(255)
#  login_count       :integer          default(0), not null
#  last_request_at   :datetime
#  last_login_at     :datetime
#  current_login_at  :datetime
#  last_login_ip     :string(255)
#  current_login_ip  :string(255)
#  perishable_token  :string(255)      default(""), not null
#  created_at        :datetime
#  updated_at        :datetime
#

class Account < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_email_field = false
    c.logged_in_timeout = 10.minutes
  end

  has_many :account_participants, :dependent => :destroy
  has_many :participants, :through => :account_participants

  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => false
  validates_presence_of :email
  validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i, :message => 'is Invalid'

  def all_participants
    participants.reject { |p| p.withdrawn? }
  end

  def active_participants
    participants.reject { |p| p.inactive? }
  end

  def inactive_participants
    participants.reject { |p| p.active? }
  end

  def other_participants(participant)
    active_participants.reject { |p| p == participant or p.inactive?}
  end

  def has_self_participant?
    account_participants.any? {|ap| ap.proxy == false and (ap.participant != nil and !ap.participant.withdrawn?)}
  end

  def child_proxy_participant
    participants.select { |p| p.active? && p.child == true and p.account_participant.proxy == true }.last
  end

  def adult_proxy_participant
    participants.select { |p| p.active? && p.child == false and p.account_participant.proxy == true }.last
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
