class StudyPolicy < ApplicationPolicy
  def index?
    is_admin?
  end

  def new?
    is_admin?
  end

  def create?
    is_admin?
  end

  def show?
    is_admin?
  end

  def edit?
    is_admin?
  end

  def update?
    is_admin?
  end

  def destroy?
    is_admin?
  end

  def activate?
    is_admin?
  end

  def deactivate?
    is_admin?
  end

  def search?
    is_admin?
  end
end