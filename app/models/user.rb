class User < ActiveRecord::Base
  # Dependencies
  include AASM

  attr_accessor :study_tokens

  # Dependencies
  # Include default devise modules. Others available are:
  devise :ldap_authenticatable, :trackable, :timeoutable

  # Associations
  has_many  :user_studies
  has_many  :studies, through: :user_studies
  has_many  :comments, as: :commentable

  # Validations
  validates_presence_of   :netid
  validate                :check_netid

  # Hooks
  after_create :update_from_ldap

  # AASM events and transitions
  aasm column: :state do
    state :active, initial: true
    state :inactive

    event :activate do
      transitions to: :active
    end

    event :deactivate do
      transitions to: :inactive
    end
  end

  # Scopes
  scope :by_state, -> (state){ where(state: state) }

  def study_tokens=(ids)
    self.user_studies.destroy_all if ids.blank?
    values = ids.split(',').collect{|val| val.to_i}
    self.user_studies.where("study_id not in (?)",values).destroy_all
    values.each do |val|
      self.user_studies.find_or_create_by(study_id: val)
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def active_participants
    studies.active.collect{|s| s.active_participants}.flatten.uniq
  end

  def has_system_access?
    ActiveRecord::Base::User.active.find_by_netid(netid).present?
  end

  def active_for_authentication?
    self.active?
  end

  private
    def check_netid
      unless Rails.env.development?
        errors.add(:netid, 'Not recognized') unless Devise::LDAP::Adapter.valid_login?(netid)
      end
    end

  def update_from_ldap
    unless Rails.env.development?
      ldap_user = Devise::LDAP::Adapter.get_ldap_entry(netid)
      self.update_attributes(
        first_name: ldap_user.givenname.first,
        last_name: ldap_user.sn.first,
        email: ldap_user.mail.first
      )
    end
  end
end
