class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private
    def is_public_user?
      user.is_a?(Account)
    end

    def is_admin?
      user.is_a?(User) && user.active? && user.admin?
    end

    def is_data_manager?
      user.is_a?(User) && user.active? && user.data_manager?
    end

    def is_researcher?
      user.is_a?(User) && user.active? && user.researcher?
    end
end
