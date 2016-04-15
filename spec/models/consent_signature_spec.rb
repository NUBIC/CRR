require 'spec_helper'

describe ConsentSignature do
  let(:consent_signature) { FactoryGirl.create(:consent_signature) }
  it 'creates a new instance given valid attributes' do
    expect(consent_signature).not_to be_nil
  end
end
