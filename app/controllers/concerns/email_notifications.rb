module EmailNotifications
  extend ActiveSupport::Concern

  def admin_email(content, subject)
    EmailNotificationsMailer.generic_email(Rails.configuration.contact_email, content, subject).deliver_now!
  end

  def outbound_email(email, content, subject)
    EmailNotificationsMailer.generic_email(email, content, subject).deliver_now!
  end
end
