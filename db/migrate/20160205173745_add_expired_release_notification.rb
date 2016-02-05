class AddExpiredReleaseNotification < ActiveRecord::Migration
  def change
    e = EmailNotification.new
    e.content = %Q{
Dear Researcher,

This is a friendly reminder that your release period has come to an end. You need to send the completed Release Report to the research coordinator at commresearchregistry@northwestern.edu by the end of today. You can find the Release Report Excel attached to the email sent on day 1 of your release period. All participants not listed as enrolled must be “returned” to the registry and their contact information forfeited. Please keep in mind that timeliness of participant returns affects your ability to use the registry in the future.

Regards,

The Communication Research Registry Team
    }
    e.activate
    e.email_type = EmailNotification::RELEASE_EXPIRED
    e.save!
  end
end
