class UpdateWelcomeEmailNotificationType < ActiveRecord::Migration
  def change
    welcome_email = EmailNotification.find_by(email_type: 'Welcome')
    welcome_email.email_type = EmailNotification::WELCOME_PARTICIPANT
    welcome_email.save!
  end
end
