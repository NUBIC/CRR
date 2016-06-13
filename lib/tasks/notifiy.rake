namespace :notify do
  desc 'Notification of expiring release'
  task :expiring_release => :environment do
    email = EmailNotification.active.release_expiring
    if email
      Search.where(warning_date: Date.today).where('end_date is null or end_date > ?', Date.today).where(state: 'data_released').each do |search|
        user_emails = search.user_emails
        if user_emails.any?
          subject = email.subject.gsub('{{search_name}}', search.name)
          EmailNotificationsMailer.generic_email(user_emails, email.content, subject).deliver_now!
          puts "Study '#{search.study.name}' researchers were notified of expiring release"
        else
          puts "Study '#{search.study.name}' researchers could not be notified of expiring release: emails are not available"
        end
      end
    else
      puts 'Email notification: email for expiring release is not available'
    end
  end

  task :expired_release => :environment do
    email = EmailNotification.active.release_expired
    if email
      Search.where(end_date: Date.today).where(state: 'data_released').each do |search|
        user_emails = search.user_emails
        if user_emails.any?
          subject = email.subject.gsub('{{search_name}}', search.name)
          EmailNotificationsMailer.generic_email(user_emails, email.content, subject).deliver_now!
          puts "Study '#{search.study.name}' researchers were notified of expired release"
        else
          puts "Study '#{search.study.name}' researchers could not be notified of expired release: emails are not available"
        end
      end
    else
      puts 'Email notification: email for expired release is not available'
    end
  end
end
