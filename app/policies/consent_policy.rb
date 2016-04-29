class ConsentPolicy < ApplicationPolicy
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
    is_admin? && record.editable?
  end

  def update?
    is_admin? && record.editable?
  end

  def destroy?
    is_admin? && record.editable?
  end

  def activate?
    is_admin? && record.inactive?
  end

  def deactivate?
    is_admin?
  end
end