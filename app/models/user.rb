# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  netid              :string(255)
#  admin              :boolean
#  researcher         :boolean
#  data_manager       :boolean
#  first_name         :string(255)
#  last_name          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :inet
#  last_sign_in_ip    :inet
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  devise :ldap_authenticatable, :trackable, :timeoutable

  has_many :user_studies
  has_many :studies, through: :user_studies

  # validates_uniqueness_of :netid, case_sensitive: false, allow_blank: false
  validates_presence_of   :netid

  validate  :check_netid
  after_create :update_from_ldap

  attr_accessor :study_tokens

  def study_tokens=(ids)
    self.user_studies.destroy_all if ids.blank?
    values = ids.split(',').collect{|val| val.to_i}
    self.user_studies.where("study_id not in (?)",values).destroy_all
    values.each do |val|
      self.user_studies.find_or_create_by_study_id(val)
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
      # if Rails.env.staging? || Rails.env.production?
        errors.add(:netid,"Not recognized") unless Devise::LDAP::Adapter.valid_login?(netid)
      # end
    end

  def update_from_ldap
    # if Rails.env.staging? || Rails.env.production?
      ldap_user = Devise::LDAP::Adapter.get_ldap_entry(netid)
      self.update_attributes(first_name: ldap_user.givenname.first, last_name: ldap_user.sn.first)
    # end
  end
end
