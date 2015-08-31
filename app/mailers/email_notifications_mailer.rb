class EmailNotificationsMailer < ActionMailer::Base
  def generic_email(email, content, email_subject)
    @content = content
    mail(from: 'commresearchregistry@northwestern.edu', to: email, subject: email_subject)
  end
end