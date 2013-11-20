class Ability
  include CanCan::Ability
  def initialize(user)
    if user.is_a?(Aker::User) 
      if user.admin?
        #control access for surveys
        can [:preview,:new,:show,:create,:deactivate,:activate], Survey do |survey|
          true
        end

        can [:edit,:update,:destroy], Survey do |survey|
          survey.inactive?
        end
        can [:show], Section do |section|
          true
        end
        can [:new,:create,:edit,:update,:destroy], Section do |section|
          section.survey.inactive?
        end
        can [:show], Question do |question|
          true
        end
        can [:new,:create,:edit,:update,:destroy], Question do |question|
          question.section.survey.inactive?
        end

        can [:show], Answer do |answer|
          true
        end
        can [:new,:create,:edit,:update,:destroy], Answer do |answer|
          answer.question.section.survey.inactive?
        end
        can [:show], ResponseSet do |response_set|
          true
        end
        can [:edit,:update], ResponseSet do |response_set|
          response_set.survey.active? and !response_set.complete?
        end
        can [:new,:create,:destroy], ResponseSet do |response_set|
          response_set.survey.active? 
        end
      elsif user.data_manager?
      else user.researcher?
      end
    else

    end
  end
end
