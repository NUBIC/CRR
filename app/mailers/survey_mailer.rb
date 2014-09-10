class SurveyMailer < ActionMailer::Base
  default :from => "commresearchregistry@northwestern.edu"

  def new_survey_alert(response_set)
    # @recipients =  [response_set.email ,response_set.participant.account.email].flatten.uniq
    @recipients = response_set.email
    mail(:to => @recipients, :subject => "Request for more information in your Registry profile")
  end

end
