class SurveyPolicy < ApplicationPolicy
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
    is_admin? && inactive_survey?
  end

  def update?
    is_admin? && inactive_survey?
  end

  def destroy?
    is_admin? && inactive_survey?
  end

  def activate?
    is_admin?
  end

  def deactivate?
    is_admin? && !((record.adult_survey? || record.child_survey?) && Rails.env.production?)
  end

  def preview?
    is_admin?
  end

  def nodes?
    is_admin?
  end

  private
    def inactive_survey?
      record.inactive?
    end
end