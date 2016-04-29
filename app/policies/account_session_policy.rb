class AccountSessionPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end

  def back_to_website?
    true
  end
end