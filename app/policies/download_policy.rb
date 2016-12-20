class DownloadPolicy < ApplicationPolicy
  def new?
    can_manage?
  end

  def create?
    can_manage?
  end

  def show?
    can_manage?
  end

  private
    def can_manage?
      is_admin? || is_data_manager?
    end
end