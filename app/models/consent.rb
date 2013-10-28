# == Schema Information
#
# Table name: consents
#
#  id           :integer          not null, primary key
#  content      :text
#  accept_text  :string(255)      default("I Accept")
#  decline_text :string(255)      default("I Decline")
#  created_at   :datetime
#  updated_at   :datetime
#

class Consent < ActiveRecord::Base
  has_many :consent_signatures
end
