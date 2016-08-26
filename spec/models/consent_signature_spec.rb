require 'rails_helper'

RSpec.describe ConsentSignature, type: :model do
  let(:consent_signature) { FactoryGirl.create(:consent_signature) }
  it 'creates a new instance given valid attributes' do
    expect(consent_signature).not_to be_nil
  end

  it 'populates default date' do
    consent_signature = ConsentSignature.new
    expect(consent_signature.date).to eq Date.today
  end
end
