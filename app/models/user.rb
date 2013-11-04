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

  def name
    "#{first_name} #{last_name}"
  end
  
end
