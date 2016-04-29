class ResponseSetPolicy < ApplicationPolicy
  def index?
    can_manage?
  end

  def new?
    can_manage?
  end

  def create?
    is_participant_owner? || can_manage? && survey_active?
  end

  def show?
    is_participant_owner? && !record.complete?
  end

  def edit?
    is_participant_owner? && !record.complete? || can_manage? && survey_active?
  end

  def update?
    is_participant_owner? && !record.complete? || can_manage? && survey_active?
  end

  def destroy?
    can_manage? && survey_active?
  end

  def load_from_file?
    can_manage?
  end

  private
    def is_participant_owner?
      is_public_user? && user == record.participant.account
    end

    def can_manage?
      is_admin? || is_data_manager?
    end

    def survey_active?
      record.survey && record.survey.active?
    end
end