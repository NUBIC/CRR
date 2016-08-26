require 'rails_helper'

RSpec.describe Consent, type: :model do
  let(:consent) { FactoryGirl.create(:consent) }

  it { is_expected.to have_many(:consent_signatures).dependent(:restrict_with_error) }
  it { is_expected.to validate_presence_of :state}

  context 'active consent' do
    before :each do
      consent.activate
      consent.save
    end
    before { subject = consent }
    it { is_expected.to validate_uniqueness_of(:state).scoped_to(:consent_type).with_message('Only one active consent per category allowed')}
  end

  context 'inactive consent' do
    before :each do
      consent.deactivate
      consent.save
    end
    before { subject = consent }
    it { is_expected.not_to validate_uniqueness_of(:state).scoped_to(:consent_type)}
  end

  it 'creates a new instance given valid attributes' do
    expect(consent).not_to be_nil
  end

  it 'sets default state' do
    consent = Consent.new
    expect(consent).to be_inactive
  end

  it 'finds active child consent' do
    expect(Consent.child_consent).to be nil

    child_consent = FactoryGirl.create(:consent, consent_type: 'Child')
    adult_consent = FactoryGirl.create(:consent, consent_type: 'Adult')
    expect(Consent.child_consent).to be nil

    child_consent.activate
    child_consent.save!
    adult_consent.activate
    adult_consent.save!
    expect(Consent.child_consent).to eq child_consent
  end

  it 'finds active adult consent' do
    expect(Consent.adult_consent).to be nil

    child_consent = FactoryGirl.create(:consent, consent_type: 'Child')
    adult_consent = FactoryGirl.create(:consent, consent_type: 'Adult')
    expect(Consent.adult_consent).to be nil

    child_consent.activate
    child_consent.save!
    adult_consent.activate
    adult_consent.save!
    expect(Consent.adult_consent).to eq adult_consent
  end

  it 'checks if consents are active' do
    expect(Consent.has_active_consent?).to be false

    child_consent = FactoryGirl.create(:consent, consent_type: 'Child')
    expect(Consent.has_active_consent?).to be false
    adult_consent = FactoryGirl.create(:consent, consent_type: 'Adult')
    expect(Consent.has_active_consent?).to be false

    child_consent.activate
    child_consent.save!
    adult_consent.activate
    adult_consent.save!

    expect(Consent.has_active_consent?).to be true
  end

  it 'checks if record is editable' do
    expect(consent).to be_editable

    consent.activate
    consent.save!
    expect(consent).not_to be_editable

    consent.deactivate
    consent.save!
    consent.consent_signatures.build
    expect(consent).not_to be_editable
  end
end
