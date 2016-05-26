class AddNameAndDescriptionToEmailNotifications < ActiveRecord::Migration
  def up
    add_column :email_notifications, :description,  :text
    add_column :email_notifications, :name,         :string
    add_column :email_notifications, :subject,      :string

    EmailNotification.all.each do |email_notification|
      email_notification.name = email_notification.email_type
      email_notification.save!
    end

    remove_column :email_notifications, :email_type, :string
    Setup.email_notifications
  end

  def down
    add_column :email_notifications, :email_type, :string

    EmailNotification.all.each do |email_notification|
      email_notification.email_type = email_notification.name
      email_notification.save!
    end

    remove_column :email_notifications, :description,  :text
    remove_column :email_notifications, :name,         :string
    remove_column :email_notifications, :subject,      :string
  end
end
