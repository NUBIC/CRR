module EmailNotifications
  extend ActiveSupport::Concern

  def admin_email(content, subject)
    EmailNotificationsMailer.generic_email(Rails.configuration.custom.app_config['contact_email'], content, subject).deliver!
  end

  def outbound_email(email, content, subject)
    EmailNotificationsMailer.generic_email(email, content, subject).deliver!
  end
end
