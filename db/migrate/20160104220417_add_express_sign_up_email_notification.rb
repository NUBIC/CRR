class AddExpressSignUpEmailNotification < ActiveRecord::Migration
  def change
    e = EmailNotification.new
    e.content = %Q{
Thank you for your interest in the Communication Research Registry. Recently, you completed the express sign up on our website. To complete your enrollment and enable you to be contacted for future studies you will need to go to https://crr.nubic.northwestern.edu and follow the steps in the “Sign Up” tab. Joining is easy and should take you no more than 15 minutes. You can also call us at 855-354-3273 and we can walk you through the sign up process over the phone if that is more convenient. If you are interested in signing up over the phone please respond to this email with the best time to call, so that we may contact you at your earliest convenience.
Thank you again for your interest in research and we hope to work with you soon!

Regards,

The Communication Research Registry Team
    }
    e.activate
    e.email_type = 'Express sign up'
    e.save!
  end
end
