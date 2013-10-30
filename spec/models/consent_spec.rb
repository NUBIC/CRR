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
#  consent_type :string(255)
#

require 'spec_helper'

describe Consent do
  let(:consent) { FactoryGirl.create(:consent) }
  it "creates a new instance given valid attributes" do
    consent.should_not be_nil
  end

  it { should have_many(:consent_signatures) }
end
