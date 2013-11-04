class Aker::Authorities::Crr
  # This authority decorates the Aker::User model with extra methods from the Aker::EnotisUser module
  def amplify!(user)
    return user.extend(Aker::CrrUser)
  end
end
