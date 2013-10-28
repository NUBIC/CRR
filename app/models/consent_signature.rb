# == Schema Information
#
# Table name: consent_signatures
#
#  id                  :integer          not null, primary key
#  consent_id          :integer
#  participant_id      :integer
#  consent_date        :date
#  consent_person_name :string(255)
#  accept              :boolean
#  created_at          :datetime
#  updated_at          :datetime
#

class ConsentSignature < ActiveRecord::Base
  belongs_to :consent
  belongs_to :participant
end
