# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  netid      :string(255)
#  admin      :boolean
#  researcher :boolean
#  first_name :string(255)
#  last_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base

  def name
  end

end
