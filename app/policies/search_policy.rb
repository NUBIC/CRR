class SearchPolicy < ApplicationPolicy
  def index?
    can_manage? || is_researcher?
  end

  def new?
    can_manage? || is_researcher?
  end

  def create?
    can_manage? || is_researcher?
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

  def request_data?
    can_manage? || is_researcher? && on_study?
  end

  def release_data?
    can_manage? && !record.data_released?
  end

  private
    def can_manage?
      is_admin? || is_data_manager?
    end

    def on_study?
      user.studies.active.include?(record.study)
    end
end