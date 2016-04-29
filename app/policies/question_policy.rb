class QuestionPolicy < ApplicationPolicy
  def index?
    is_admin?
  end

  def new?
    is_admin? && inactive_survey?
  end

  def create?
    is_admin? && inactive_survey?
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

  def search?
    is_admin?
  end

  private
    def inactive_survey?
      record.section.survey.inactive?
    end
end