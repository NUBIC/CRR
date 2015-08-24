class EmailNotificationsMailer < ActionMailer::Base
  def generic_email(email, content, email_subject)
    @content = content
    @email_subject = email_subject
    mail(from: 'commresearchregistry@northwestern.edu', to: email, subject: email_subject) do |format|
      format.html { render layout: 'email'}
    end
  end
end