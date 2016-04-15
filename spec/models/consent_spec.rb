require 'spec_helper'

describe Consent do
  it { is_expected.to have_many(:consent_signatures) }

  let(:consent) { FactoryGirl.create(:consent) }
  it 'creates a new instance given valid attributes' do
    expect(consent).not_to be_nil
  end
end
