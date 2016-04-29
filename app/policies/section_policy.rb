class SectionPolicy < ApplicationPolicy
  def new?
    is_admin? && survey_inactive?
  end

  def create?
    is_admin? && survey_inactive?
  end

  def show?
    is_admin?
  end

  def edit?
    is_admin? && survey_inactive?
  end

  def update?
    is_admin? && survey_inactive?
  end

  def destroy?
    is_admin? && survey_inactive? && record.survey.multiple_section?
  end

  private
    def survey_inactive?
      record.survey.inactive?
    end
end