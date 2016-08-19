require 'rails_helper'

RSpec.describe Participant, type: :model do
  let(:participant) { FactoryGirl.create(:participant) }
  it 'creates a new instance given valid attributes' do
    expect(participant).not_to be_nil
  end

  it { is_expected.to have_many(:origin_relationships) }
  it { is_expected.to have_many(:destination_relationships) }
  it { is_expected.to have_many(:study_involvements) }
  it { is_expected.to have_many(:contact_logs) }
  it { is_expected.to validate_length_of(:zip).is_at_most(5) }
  it { is_expected.to validate_numericality_of(:zip) }

  describe '#name' do
    it 'joins first name and last name' do
      participant = FactoryGirl.build(:participant, first_name: 'Brian', last_name: 'Lee')
      expect(participant.name).to eq 'Brian Lee'
    end
  end

  describe '#address' do
    [
      ['123 Main St', 'Apt #111', 'Chicago', 'IL', '12345', 'prints out correctly with all field', '123 Main St Apt #111 Chicago, IL 12345'],
      [nil, 'Apt #111', 'Chicago', 'IL', '12345', 'prints out correctly with striping out empty "address line1"', 'Apt #111 Chicago, IL 12345' ],
      ['123 Main St', '', 'Chicago', 'IL', '12345', 'prints out correctly with striping out empty "address line2"', '123 Main St Chicago, IL 12345'],
      ['123 Main St', 'Apt #111', '', 'IL', '12345', 'prints out correctly with striping out empty "city"', '123 Main St Apt #111, IL 12345'],
      ['123 Main St', 'Apt #111', 'Chicago', '', '12345', 'prints out correctly with striping out empty "state"', '123 Main St Apt #111 Chicago, 12345'],
      ['123 Main St', 'Apt #111', 'Chicago', 'IL', nil, 'prints out correctly with striping out empty "zip"', '123 Main St Apt #111 Chicago, IL'],
      ['123 Main St', 'Apt #111', 'Chicago', '', nil, 'prints out correctly with striping out empty "state" and "zip"', '123 Main St Apt #111 Chicago']
    ].each do |a_1, a_2, c, s, z, test, result|
      it "#{test}" do
        participant = FactoryGirl.build(:participant, address_line1: a_1, address_line2: a_2, city: c, state: s, zip: z)
        expect(participant.address).to eq "#{result}"
      end
    end

    it 'returns nil for all nil or empty address field' do
      participant = FactoryGirl.build(:participant)
      expect(participant.address).to be_nil
    end
  end

  describe '#seach_display' do
    it 'includes names' do
      participant = FactoryGirl.build(:participant, first_name: 'Brian', last_name: 'Lee')
      expect(participant.search_display).to eq 'Brian Lee'
    end

    it 'includes names and address' do
      participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345', first_name: 'Brian', last_name: 'Lee')
      expect(participant.search_display).to eq 'Brian Lee - 123 Main St Apt #111 Chicago, IL 12345'
    end

    it 'includes names, address and email' do
      participant = participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345', email: 'email@test.com', first_name: 'Brian', last_name: 'Lee')
      expect(participant.search_display).to eq 'Brian Lee - 123 Main St Apt #111 Chicago, IL 12345 - email@test.com'
    end

    it 'includes names' do
      participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345', email: 'email@test.com', primary_phone: '1234567890', first_name: 'Brian', last_name: 'Lee')
      expect(participant.search_display).to eq 'Brian Lee - 123 Main St Apt #111 Chicago, IL 12345 - email@test.com - 1234567890'
    end
  end

  describe '#validates' do
    [ '(123) 456 7899',
      '(123).456.7899',
      '(123)-456-7899',
      '123-456-7899',
      '123 456 7899',
      '1234567899'
    ].each do |phone|
      it "allows #{phone} as valid primary_phone" do
        participant = FactoryGirl.create(:participant, primary_phone: phone)
        expect(participant).to be_valid
      end

      it "allows #{phone} as valid secondary_phone" do
        participant = FactoryGirl.create(:participant, secondary_phone: phone)
        expect(participant).to be_valid
      end
    end

    it 'does not allow phone with alphabets as a valid primary_phone' do
      participant = FactoryGirl.build(:participant, primary_phone: '123ABC3456')
      expect(participant).not_to be_valid
    end

    it 'does not allow phone with alphabets as a valid secondary_phone' do
      participant = FactoryGirl.build(:participant, secondary_phone: '123ABC3456')
      expect(participant).not_to be_valid
    end
  end

  describe 'search scope' do
    it 'returns all the participant with first_name or last_name with "J"' do
      par1 = FactoryGirl.create(:participant, first_name: 'Jacob')
      par2 = FactoryGirl.create(:participant, last_name: 'jim')
      par3 = FactoryGirl.create(:participant, first_name: 'My', last_name: 'Little')

      partcipants = Participant.search('j')
      expect(partcipants).to match_array([par1, par2])
    end
  end

  it 'includes origin_relationships and destination_relationships' do
    sib1 = FactoryGirl.create(:participant, first_name: 'Jacob')
    sib2 = FactoryGirl.create(:participant)
    parent = FactoryGirl.create(:participant, first_name: 'Martha')

    @rel1 = FactoryGirl.create(:relationship, origin: sib1, destination: sib2)
    @rel2 = FactoryGirl.create(:relationship, category: 'Parent', origin: parent, destination: sib1)
    @rel3 = FactoryGirl.create(:relationship, category: 'Parent', origin: parent, destination: sib2)

    @relationships = sib1.relationships

    expect(@relationships).to match_array([@rel1, @rel2])
  end

  context 'proxy' do
    let(:account) { FactoryGirl.create(:account) }

    describe '#proxy?' do
      it 'retruns true if account_participant has proxy' do
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        expect(participant).to be_proxy
      end

      it 'retruns false if account_participant has proxy' do
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        expect(participant).not_to be_proxy
      end
    end

    describe '#adult_proxy?' do
      it 'retruns true if account_participant has proxy and participant is not child' do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        expect(participant).to be_adult_proxy
      end

      it 'retruns false if account_participant has proxy and participant is child' do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        expect(participant).not_to be_adult_proxy
      end

      it 'retruns false if account_participant has no proxy and participant is child' do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        expect(participant).not_to be_adult_proxy
      end

      it 'retruns false if account_participant has no proxy and participant is not child' do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        expect(participant).not_to be_adult_proxy
      end
    end

    describe '#child_proxy?' do
      it 'retruns true if account_participant has proxy and participant is child' do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        expect(participant).to be_child_proxy
      end

      it 'retruns false if account_participant has proxy and participant is not child' do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        expect(participant).not_to be_child_proxy
      end

      it 'retruns false if account_participant has no proxy and participant is child' do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        expect(participant).not_to be_child_proxy
      end

      it 'retruns false if account_participant has no proxy and participant is not child' do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        expect(participant).not_to be_child_proxy
      end
    end
  end

  describe '#on_study?' do
    let(:study) { FactoryGirl.create(:study, state: 'active') }

    it 'returns true if participant has any study involvement with start date is in past and end date is in future' do
      FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 2.days.ago, end_date: 2.days.from_now)
      expect(participant).to be_on_study
    end

    it 'returns false if participant has any study involvement with start date is in future' do
      si = FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 2.days.from_now, end_date: 4.days.from_now)
      expect(participant).not_to be_on_study
    end

    it 'returns false if participant has any study involvement with end date is in past' do
      FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 4.days.ago, end_date: 2.days.ago)
      expect(participant).not_to be_on_study
    end

    # By design we allow to participant to be added to the inactive study.
    it 'should return true if association dates are within range and study is inactive' do
      study.state = 'inactive'
      study.save
      study.reload
      FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 2.days.ago, end_date: 2.days.from_now)
      expect(participant).to be_on_study
    end
  end

  describe '#recent_response_set' do
    it 'should return last updated_at response_set' do
      survey = FactoryGirl.create(:survey, multiple_section: true)
      res1 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res2 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res3 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res2.updated_at = Time.now + 10.minutes
      res2.save
      expect(participant.recent_response_set).to eq res2
    end
  end

  describe '#has_followup_survey?' do
    it 'should return false if participant has child survey' do
      survey = FactoryGirl.create(:survey, multiple_section: true, code: 'child')
      FactoryGirl.create(:response_set, participant: participant, survey: survey)
      expect(participant).not_to have_followup_survey
    end
  end

  describe '#open?' do
    [:consent, :demographics, :survey].each do |st|
      it "should return true if participant has state '#{st.to_s}'" do
        participant.stage = st
        expect(participant).to be_open
      end
    end
  end

  describe '#consented?' do
    [:demographics, :completed, :survey, :pending_approval, :approved].each do |st|
      it "should return true if participant has state '#{st.to_s}' and has consent" do
        FactoryGirl.create(:consent_signature, consent: FactoryGirl.create(:consent), participant: participant)
        participant.stage = st
        expect(participant).to be_consented
      end
    end

    [:demographics, :completed, :survey, :pending_approval, :approved].each do |st|
      it "should return false if participant has state '#{st.to_s}' but no consent" do
        participant.stage = st
        expect(participant).not_to be_consented
      end
    end
  end

  describe '#completed?' do
    [:pending_approval, :approved].each do |st|
      it "should return true if participant has state '#{st.to_s}'" do
        participant.stage = st
        expect(participant).to be_completed
      end
    end
  end

  describe '#inactive?' do
    [:consent, :demographics].each do |st|
      it "should return true if participant has state '#{st.to_s}'" do
        participant.stage = st
        expect(participant).to be_inactive
      end
    end
  end

  describe '#copy_from' do
    let(:other) { FactoryGirl.create(:participant, address_line1: '123 Main St', address_line2: 'Apt #123', city: 'Chicago',
      state: 'IL', zip: '12345', email: 'test@test.com', primary_phone: '123-456-7890', secondary_phone: '123-345-6789')}

    before(:each) do
      participant.copy_from(other)
    end

    it 'copies address_line1 from other participant' do
      expect(participant.address_line1).to eq other.address_line1
    end

    it 'copies address_line2 from other participant' do
      expect(participant.address_line2).to eq other.address_line2
    end

    it 'copies city from other participant' do
      expect(participant.city).to eq other.city
    end

    it 'copies state from other participant' do
      expect(participant.state).to eq other.state
    end

    it 'copies zip from other participant' do
      expect(participant.zip).to eq other.zip
    end

    it 'copies email from other participant' do
      expect(participant.email).to eq other.email
    end

    it 'copies primary_phone from other participant' do
      expect(participant.primary_phone).to eq other.primary_phone
    end

    it 'copies secondary_phone from other participant' do
      expect(participant.secondary_phone).to eq other.secondary_phone
    end
  end
end
