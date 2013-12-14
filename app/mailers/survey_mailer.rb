class SurveyMailer < ActionMailer::Base
  default :from => "noreply@commresearchregistry.northwestern.edu"

  def new_survey_alert(response_set)
    @recipients =  [response_set.participant.email ,response_set.participant.account.email].flatten.uniq
    mail(:to => @recipients, :subject => "Request for more information in your Registry profile")
  end

end
