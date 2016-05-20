class SearchPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.with_user(user)
      end
    end
  end

  def index?
    can_manage? || is_researcher?
  end

  def new?
    can_manage? || is_researcher?
  end

  def create?
    can_manage? || is_researcher? && on_study?
  end

  def show?
    can_manage? || is_researcher? && on_study?
  end

  def edit?
    can_manage? && !record.data_released? || is_researcher? && on_study? && record.new?
  end

  def update?
    can_manage? && !record.data_released? || is_researcher? && on_study? && record.new?
  end

  def destroy?
    can_manage? && !record.data_released? || is_researcher? && on_study? && record.new?
  end

  def copy?
    can_manage? || is_researcher? && on_study?
  end

  def request_data?
    (can_manage? || is_researcher? && on_study?) && !record.data_requested?
  end

  def release_data?
    can_manage? && !record.data_released?
  end

  def return_data?
    (can_manage? || is_researcher? && on_study?) && record.data_released?
  end

  def view_results?
    can_manage? || (is_researcher? && on_study? && record.data_released?)
  end

  private
    def can_manage?
      is_admin? || is_data_manager?
    end

    def on_study?
      user.studies.active.include?(record.study)
    end
end