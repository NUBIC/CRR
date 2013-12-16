class AccountSession  < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session
  self.logout_on_timeout = true
  self.remember_me = false

  def to_key
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end

  def persisted?
    false
  end

end