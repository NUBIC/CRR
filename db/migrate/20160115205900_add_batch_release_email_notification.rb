class AddBatchReleaseEmailNotification < ActiveRecord::Migration
  def change
    e = EmailNotification.new
    e.content = %Q{
Dear Researcher,

Your recent request for participants has been approved. To see a list of all participants released under this request, please log into the Communication Research Registry website (https://crr.nubic.northwestern.edu/admin) and click on the "Requests" -> "Data Released".

Please feel free to get in touch with us by phone (855-354-3273) or email commresearchregistry@northwestern.edu if you have any questions about the registry.
    }
    e.activate
    e.email_type = EmailNotification::BATCH_RELEASED
    e.save!
  end
end


