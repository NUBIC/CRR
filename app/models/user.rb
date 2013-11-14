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

  private
  def update_from_ldap
  end
  
end
