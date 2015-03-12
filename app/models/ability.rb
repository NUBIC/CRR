class Ability
  include CanCan::Ability
  def initialize(user)
    if user.is_a?(Aker::User)
      if user.admin?
        #control access for surveys
        can [:preview,:new,:show,:create,:deactivate,:activate,:index], Survey

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
        can [:new,:create,:show,:activate,:deactivate,:index], Consent
        can [:edit,:update,:destroy], Consent do |consent|
          consent.editable?
        end
        can :manage, Study
        can :manage, Search
        can :manage, User
        can :manage, Participant
        can :manage, Relationship
        can :manage, ResponseSet
        can :manage, ContactLog
        can :manage, StudyInvolvement
      elsif user.data_manager?
        can :manage, Participant
        can :manage, Relationship
        can :manage, ResponseSet
        can :manage, Search
        can :manage, ContactLog
        can :manage, StudyInvolvement
      else user.researcher?
        can [:show], Participant do |participant|
          !(participant.study_involvements.active.collect{|si| si.study}.flatten & user.studies.active).empty?
        end
        can [:show,:request_data], Search do |search|
          user.studies.active.include?(search.study)
        end
        can :destroy, Search do |search|
          user.studies.active.include?(search.study) && search.new?
        end
      end
    elsif user.is_a?(Account)
      can [:update, :edit, :dashboard, :destroy], Account do |account|
        account == user
      end

      can [:update, :enroll, :consent, :show, :create, :consent_signature], Participant do |participant|
        participant.try(:account) == user
      end

      can [:new, :create, :edit, :update, :show], ResponseSet do |response_set|
        response_set.try(:participant).try(:account) == user && !response_set.complete?
      end
    else

    end
  end
end
