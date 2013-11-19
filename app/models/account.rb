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
  end

  has_many :account_participants
  has_many :participants, :through => :account_participants

  validates_uniqueness_of   :email, :case_sensitive => false, :allow_blank => false
  validates_presence_of :email
  validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i, :message => 'is Invalid'

  def active_participants
    participants.reject { |p| p.withdrawn? }
  end

  def has_active_participants?
    active_participants.size > 0
  end

  def inactive_participants
    participants.select { |p| p.inactive? }
  end

  def has_self_participant?
    account_participants.detect {|ap| ap.proxy == false && ap.participant.consented? }
  end
end
