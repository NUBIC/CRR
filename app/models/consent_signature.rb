# == Schema Information
#
# Table name: consent_signatures
#
#  id                 :integer          not null, primary key
#  consent_id         :integer
#  participant_id     :integer
#  date               :date
#  proxy_name         :string(255)
#  proxy_relationship :string(255)
#  entered_by         :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class ConsentSignature < ActiveRecord::Base
  belongs_to :consent
  belongs_to :participant

  validates_presence_of :date,:participant,:consent

  after_initialize :default_args

  private
  def default_args
    self.date ||=Date.today
  end
end
