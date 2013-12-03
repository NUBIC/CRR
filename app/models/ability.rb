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
        can [:new,:create,:edit,:update,:destroy,:show,:activate,:deactivate], Study do |study|
          true
        end
        can [:new,:create,:show,:activate,:deactivate], Consent do |consent|
          true
        end
        can [:edit,:update,:destroy], Consent do |consent|
          consent.editable?
        end
        can [:new,:create,:show,:edit,:update,:destroy], User do |user|
          true
        end
        can [:new,:create,:edit,:update,:destroy,:show,:enroll,:consent,:consent_signature], Participant do |participant|
          true
        end
        can [:new,:create,:edit,:update,:destroy,:show], Relationship do |relationship|
          true
        end
        can [:new,:create,:edit,:update,:destroy,:show], ResponseSet do |response_set|
          true
        end
      elsif user.data_manager?
        can [:new,:create,:edit,:update,:destroy,:show,:enroll,:consent,:consent_signature], Participant do |participant|
          true
        end
        can [:new,:create,:edit,:update,:destroy,:show], Relationship do |relationship|
          true
        end
        can [:new,:create,:edit,:update,:destroy,:show], ResponseSet do |response_set|
          true
        end
      else user.researcher?
        can [:show], Participant do |participant|
          !(participant.study_involvements.active.collect{|si| si.study}.flatten & user.studies.active).empty?
        end
      end
    elsif user.is_a?(Account)
      can [:update, :edit, :dashboard, :destroy], Account do |account|
        account == user
      end

      can [:create, :update, :enroll, :consent, :consent_signature, :show], Participant do |participant|
        participant.try(:account) == user
      end

      can [:new, :create, :edit, :update, :show], ResponseSet do |response_set|
        response_set.try(:participant).try(:account) == user
      end
    else

    end
  end
end
