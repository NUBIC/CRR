# == Schema Information
#
# Table name: users
#
#  id           :integer          not null, primary key
#  netid        :string(255)
#  admin        :boolean
#  researcher   :boolean
#  data_manager :boolean
#  first_name   :string(255)
#  last_name    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class User < ActiveRecord::Base

  has_many :user_studies
  has_many :studies,:through=>:user_studies

  validates_uniqueness_of   :netid, :case_sensitive => false, :allow_blank => false

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

  def name
    "#{first_name} #{last_name}"
  end

  def active_participants
    studies.active.collect{|s| s.active_participants}.flatten.uniq
  end

  private

  def check_netid
    if Rails.env.staging? || Rails.env.production?
      errors.add(:netid,"Not recognized") if Aker.authority.find_user(netid).nil?
    end
  end
  def update_from_ldap
    if Rails.env.staging? || Rails.env.production?
      aker_user = Aker.authority.find_user(netid)
      self.update_attributes(:first_name => aker_user.first_name, :last_name => aker_user.last_name)
    end
  end

end
