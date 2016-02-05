namespace :notify do
  desc 'Notification of expiring release'
  task :expiring_release => :environment do
    email = EmailNotification.active.find_by(email_type: EmailNotification::RELEASE_EXPIRING)
    if email
      Search.where(warning_date: Date.today).where('end_date is null or end_date > ?', Date.today).each do |search|
        user_emails = search.study.user_emails
        if user_emails.any?
          EmailNotificationsMailer.generic_email(user_emails, email.content, "Communication Research Registry: Research release for '#{search.name}' report is expiring soon.").deliver!
          Rails.logger.info("Study '#{search.study.name}' researchers were notified of expiring release")
        end
      end
    else
      Rails.logger.error('Email notification: email for expiring release is not available')
    end
  end
end
