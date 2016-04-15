class User < ActiveRecord::Base
  attr_accessor :study_tokens

  # Dependencies
  # Include default devise modules. Others available are:
  devise :ldap_authenticatable, :trackable, :timeoutable

  # Associations
  has_many :user_studies
  has_many :studies, through: :user_studies

  # Validations
  validates_presence_of   :netid
  validate  :check_netid

  # Hooks
  after_create :update_from_ldap

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

  def active_study_involvements
    studies.active.collect{|s| s.study_involvements.active}.flatten
  end

  def has_system_access?
    !ActiveRecord::Base::User.find_by_netid(netid).nil?
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
      self.update_attributes(first_name: ldap_user.givenname.first, last_name: ldap_user.sn.first, email: ldap_user.mail.first)
    end
  end
end
