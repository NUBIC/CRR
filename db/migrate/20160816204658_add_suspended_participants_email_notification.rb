class AddSuspendedParticipantsEmailNotification < ActiveRecord::Migration
  def up
    e = EmailNotification.new(
      name: 'Suspended participants',
      description: 'Email notification sent daily to remind of participants suspended due to turning 18 in a month.',
      subject: 'Communication Research Registry: Participants suspended.'
    )
    e.content = %Q{
Dear CRR staff,

This is a friendly reminder that there are participants that have recently been moved to the suspended list.  To see a list of all participants “suspended”, please log into the Communication Research Registry website (https://crr.nubic.northwestern.edu/admin) and click on the "Participants" -> "Suspended." Remember that for these participants to continue to be in the Registry you will need to contact their parent/guardian for the participant’s contact information and sign them up as a separate adult participant. If they choose to not sign up for an adult account, please be sure that all their minor participant data is deleted off the CRR server (this includes their video files).
}
    e.activate
    e.save!
  end

  def down
    EmailNotification.suspended_participants.delete
  end
end
