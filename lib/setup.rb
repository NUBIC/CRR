module Setup
  def self.email_notifications
    configuration = YAML.load(ERB.new(File.read('lib/data/email_notifications.yml')).result)
    configuration.each do |mailer|
      email_notification = EmailNotification.where(name: mailer['name']).first_or_initialize
      email_notification.name = mailer['name']
      email_notification.description = mailer['description']
      email_notification.subject = mailer['subject']
      email_notification.content = mailer['content']
      email_notification.activate if email_notification.state.blank?
      email_notification.save!
    end
  end
end
