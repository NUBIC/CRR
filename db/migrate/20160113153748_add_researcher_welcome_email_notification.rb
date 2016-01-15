class AddResearcherWelcomeEmailNotification < ActiveRecord::Migration
  def change
    e = EmailNotification.new
    e.content = %Q{
Dear Researcher,

Welcome to the Communication Research Registry. Your account has been created. You may log in with you Northwestern netID and password here:
https://crr.nubic.northwestern.edu/admin
Please feel free to get in touch with us by phone (855-354-3273) or email commresearchregistry@northwestern.edu if you have any questions about the registry.

The Communication Research Registry Team
    }
    e.activate
    e.email_type = EmailNotification::WELCOME_RESEARCHER
    e.save!
  end
end
