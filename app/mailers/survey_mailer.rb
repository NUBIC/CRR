class SurveyMailer < ActionMailer::Base
  default :from => "noreply@commresearchregistry.northwestern.edu"

  def new_survey_alert(response_set)
    @recipients =  [response_set.particpant.email ,response_set.participant.account.email].flatten.uniq
    mail(:to => @recipients, :subject => "[registry] survey alert")
  end

end
