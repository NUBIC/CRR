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

require 'spec_helper'

describe ConsentSignature do
  let(:consent_signature) { FactoryGirl.create(:consent_signature) }
  it "creates a new instance given valid attributes" do
    consent_signature.should_not be_nil
  end
end
