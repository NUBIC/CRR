class AddExpiringReleaseNotification < ActiveRecord::Migration
  def change
    e = EmailNotification.new
    e.content = %Q{
This is a friendly reminder that you have a week left to contact your current batch of 20 participants. After next week you will need to “return” the participants who you have not yet contacted, have been excluded, or have declined. Please remember to update the Release Report as it is due back to the registry coordinator at the end of the two week release period.

Regards,

The Communication Research Registry Team
    }
    e.activate
    e.email_type = EmailNotification::RELEASE_EXPIRING
    e.save!
  end
end
