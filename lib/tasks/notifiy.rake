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
          puts "#{Date.today.to_s} - Study '#{search.study.name}' researchers were notified of expiring release"
        else
          puts "#{Date.today.to_s} - Study '#{search.study.name}' researchers could not be notified of expiring release: emails are not available"
        end
      end
    else
      puts 'Email notification: email for expiring release is not available'
    end
  end

  desc 'Notification of expired release'
  task :expired_release => :environment do
    email = EmailNotification.active.release_expired
    if email
      Search.where(end_date: Date.today).where(state: 'data_released').each do |search|
        user_emails = search.user_emails
        if user_emails.any?
          subject = email.subject.gsub('{{search_name}}', search.name)
          EmailNotificationsMailer.generic_email(user_emails, email.content, subject).deliver_now!
          puts "#{Date.today.to_s} - Study '#{search.study.name}' researchers were notified of expired release"
        else
          puts "#{Date.today.to_s} - Study '#{search.study.name}' researchers could not be notified of expired release: emails are not available"
        end
      end
    else
      puts 'Email notification: email for expired release is not available'
    end
  end

  desc 'Notification of suspended participants'
  task :suspended_participants => :environment do
    suspended_participants = []
    Participant.where(child: true).approved.each do |participant|
      if participant.age(Date.today + 1.month) >= 18
        participant.suspend!
        suspended_participants << participant
        puts "#{Date.today.to_s} - Participant #{participant.id} is suspended due to age restrictions"
      end
    end
    if suspended_participants.any?
      email = EmailNotification.active.suspended_participants
      if email.present?
        EmailNotificationsMailer.generic_email(Rails.configuration.contact_email, email.content, email.subject).deliver_now!
      end
    end
  end

  desc 'Annual followup'
  task :annual_followup => :environment do
    email = EmailNotification.active.annual_followup
    if email.present?
      Participant.all.each do |participant|
        if participant.birthdate.present?
          birthdate = Date.parse(participant.birthdate)
          if birthdate.day == Date.today.day && birthdate.month == Date.today.month
            emails = [participant.account.email]
            emails << participant.email unless participant.email.blank?
            emails << participant.primary_guardian_email unless participant.primary_guardian_email.blank?
            emails << participant.secondary_guardian_email unless participant.secondary_guardian_email.blank?

            EmailNotificationsMailer.generic_email(emails.uniq, email.content, email.subject, true).deliver_now!
            puts "#{Date.today.to_s} - Followup email had been sent to participant #{participant.id}"
          end
        end
      end
    end
  end
end
