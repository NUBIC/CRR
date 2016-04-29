class SearchConditionGroupPolicy < ApplicationPolicy
  def create?
    can_manage?
  end

  def update?
    can_manage?
  end

  def destroy?
    can_manage?
  end

  private
    def can_manage?
      is_admin? || is_data_manager? || is_researcher?
    end
end