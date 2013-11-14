module Aker::CrrUser
  # This module contains methods that will extend the Aker::User model

  def studies
    ActiveRecord::Base::User.find_by_netid(netid).studies
  end

  def name
    full_name
  end

  def netid
    username
  end


  def has_system_access?
    !ActiveRecord::Base::User.find_by_netid(netid).nil?
  end

  def admin?
   ActiveRecord::Base::User.find_by_netid(netid).admin?
  end
  def researcher?
   ActiveRecord::Base::User.find_by_netid(netid).researcher?
  end
  def data_manager?
   ActiveRecord::Base::User.find_by_netid(netid).data_manager?
  end

end
