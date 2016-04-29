class SearchConditionPolicy < ApplicationPolicy
  def new?
    can_manage?
  end

  def create?
    can_manage?
  end

  def show?
    can_manage?
  end

  def edit?
    can_manage?
  end

  def update?
    can_manage?
  end

  def destroy?
    can_manage?
  end

  def values?
    can_manage?
  end

  private
    def can_manage?
      is_admin? || is_data_manager? || is_researcher?
    end
end