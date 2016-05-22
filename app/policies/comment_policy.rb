class CommentPolicy < ApplicationPolicy
  # Scope comments by policy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  def index?
    can_manage? || is_researcher? && on_study?
  end

  def new?
    can_manage? || is_researcher? && on_study?
  end

  def create?
    can_manage? || is_researcher? && on_study?
  end

  def destroy?
    can_manage? || owner?
  end

  private
    def can_manage?
      is_admin? || is_data_manager?
    end

    def on_study?
      user.studies.active.include?(record.commentable.study)
    end

    def owner?
      record.user == user
    end
end