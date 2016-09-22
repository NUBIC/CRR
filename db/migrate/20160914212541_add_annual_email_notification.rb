class AddAnnualEmailNotification < ActiveRecord::Migration
  def up
    e = EmailNotification.new(
      name: 'Anual followup',
      description: 'Email notification sent to each participant on the recorded date of birth.',
      subject: 'Communication Research Registry: Happy Birthday!.'
    )
    e.content = %Q{
Happy birthday from all of us at Northwestern University’s Communication Research Registry (CRR)! We appreciate you being a part of the CRR and helping us support the cutting edge research on human communication, language, hearing, and development at Northwestern University.

If you have any questions, or would like to update your contact information, please feel free to email commresearchregistry@northwestern.edu or call 855-354-3273.

Sincerely,
The Northwestern Communication Research Registry Team
}
    e.activate
    e.save!
  end

  def down
    EmailNotification.annual_followup.delete
  end
end
