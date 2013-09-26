class Ability
  include CanCan::Ability
  def initialize(user)
    #if user.admin? #user.permit?(:admin)
      #can [:show], Activity do |activity|
      #  activity.schedule.study.has_coordinator?(user) 
      #end
    #end
  end
end
