class Ability
  include CanCan::Ability
  def initialize(user)
    if user.admin? #user.permit?(:admin)
      can :manage, :all
    else

    end
  end
end
