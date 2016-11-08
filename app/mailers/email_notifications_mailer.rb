class EmailNotificationsMailer < ActionMailer::Base
  def generic_email(email, content, email_subject, bcc=false)
    @content = content
    if bcc
      mail(from: 'commresearchregistry@northwestern.edu', to: email, subject: email_subject, bcc: 'commresearchregistry@northwestern.edu')
    else
      mail(from: 'commresearchregistry@northwestern.edu', to: email, subject: email_subject)
    end
  end
end