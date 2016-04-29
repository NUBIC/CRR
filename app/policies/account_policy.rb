class AccountPolicy < ApplicationPolicy
  def create?
    true
  end

  def edit?
    is_owner?
  end

  def update?
    is_owner?
  end

  def dashboard?
    is_owner?
  end

  def express_sign_up?
    true
  end

  def reset_password_create?
    true
  end

  def reset_password_edit?
    true
  end

  def reset_password_update?
    true
  end

  def is_owner?
    is_public_user? && user == record
  end
end