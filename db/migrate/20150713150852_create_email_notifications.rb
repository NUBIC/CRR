class CreateEmailNotifications < ActiveRecord::Migration
  def change
    create_table :email_notifications do |t|
      t.string :state
      t.text   :content
      t.string :email_type

      t.timestamps
    end

    e = EmailNotification.new
    e.content = %Q{

Thank you for signing up for the communication research registry. We have received your information and we will contact you when a compatible experiment becomes available. Please note that you may not hear from us for a couple of months because most studies focus on a very specific criteria. However, you can trust that we will contact you when you are eligible for one of our studies

Please feel free to get in touch with us by phone (855-354-3273) or email (commresearchregistry@northwestern.edu) if you have any questions about the registry.

Thank you,

The Communication Research Registry Team
    }
    e.activate
    e.email_type = 'Welcome'
    e.save!
  end
end
