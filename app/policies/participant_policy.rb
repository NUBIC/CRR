class ParticipantPolicy < ApplicationPolicy
  def index?
    can_manage?
  end

  def new?
    can_manage?
  end

  def create?
    is_public_user? || can_manage?
  end

  def show?
    is_owner? || can_manage? || released_for_research?
  end

  def edit?
    can_manage?
  end

  def update?
    is_owner? || can_manage?
  end

  def global?
    can_manage?
  end

  def enroll?
    is_owner? || can_manage?
  end

  def consent?
    is_owner?
  end

  def consent_signature?
    is_owner? || can_manage?
  end

  def withdraw?
    can_manage?
  end

  def suspend?
    can_manage?
  end

  def verify?
    can_manage?
  end

  def search?
    can_manage?
  end

  private
    def is_owner?
      is_public_user? && user == record.account
    end

    def can_manage?
      is_admin? || is_data_manager?
    end

    def released_for_research?
      is_researcher? && !(record.study_involvements.active.collect{|si| si.study}.flatten & user.studies.active).empty?
    end
end