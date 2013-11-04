# == Schema Information
#
# Table name: consents
#
#  id           :integer          not null, primary key
#  content      :text
#  active_on    :date
#  inactive_on  :date
#  accept_text  :string(255)      default("I Accept")
#  decline_text :string(255)      default("I Decline")
#  created_at   :datetime
#  updated_at   :datetime
#  consent_type :string(255)
#

class Consent < ActiveRecord::Base
  has_many :consent_signatures

  TYPES = ['Adult','Child']

  def self.active_consent
    Consent.all.last
  end
end
