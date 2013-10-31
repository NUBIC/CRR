module Aker::CrrUser
  # This module contains methods that will extend the Aker::User model

  def involvements
    Involvement.with_user(self.netid)
  end
  def studies
    Study.with_user(username)
  end
  def subjects
    Subject.with_user(username)
  end

  def roles
    Role.find_all_by_netid(username,:include=>:study)
  end
  def name
    full_name
  end
  def netid
    username
  end
  def admin?
    ENOTIS_ROLES['admin'].collect{|admin| admin['netid']}.include?(username)
  end

end
