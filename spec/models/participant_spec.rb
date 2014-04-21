# == Schema Information
#
# Table name: participants
#
#  id                            :integer          not null, primary key
#  email                         :string(255)
#  first_name                    :string(255)
#  middle_name                   :string(255)
#  last_name                     :string(255)
#  primary_phone                 :string(255)
#  secondary_phone               :string(255)
#  address_line1                 :string(255)
#  address_line2                 :string(255)
#  city                          :string(255)
#  state                         :string(255)
#  zip                           :string(255)
#  stage                         :string(255)
#  do_not_contact                :boolean
#  child                         :boolean
#  notes                         :text
#  primary_guardian_first_name   :string(255)
#  primary_guardian_last_name    :string(255)
#  primary_guardian_email        :string(255)
#  primary_guardian_phone        :string(255)
#  secondary_guardian_first_name :string(255)
#  secondary_guardian_last_name  :string(255)
#  secondary_guardian_email      :string(255)
#  secondary_guardian_phone      :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#

require 'spec_helper'

describe Participant do
  let(:participant) { FactoryGirl.create(:participant) }
  it "creates a new instance given valid attributes" do
    participant.should_not be_nil
  end

  it { should have_many(:origin_relationships) }
  it { should have_many(:destination_relationships) }
  it { should have_many(:study_involvements) }
  it { should have_many(:contact_logs) }
  it { should ensure_length_of(:zip).is_at_most(5) }
  it { should validate_numericality_of(:zip) }

  describe '#name' do
    it 'joins first name and last name' do
      participant = FactoryGirl.build(:participant,:first_name=>"Brian",:last_name=>"Lee")
      participant.name.should == "Brian Lee"
    end
  end

  describe '#address' do
    [
      ['123 Main St', 'Apt #111', 'Chicago', 'IL', '12345', "prints out correctly with all field", "123 Main St Apt #111 Chicago,IL 12345"],
      [nil, 'Apt #111', 'Chicago', 'IL', '12345', "prints out correctly with striping out empty 'address line1'", "Apt #111 Chicago,IL 12345" ],
      ['123 Main St', '', 'Chicago', 'IL', '12345', "prints out correctly with striping out empty 'address line2'", "123 Main St Chicago,IL 12345"],
      ['123 Main St', 'Apt #111', '', 'IL', '12345', "prints out correctly with striping out empty 'city'", "123 Main St Apt #111,IL 12345"],
      ['123 Main St', 'Apt #111', 'Chicago', '', '12345', "prints out correctly with striping out empty 'state'", "123 Main St Apt #111 Chicago,12345"],
      ['123 Main St', 'Apt #111', 'Chicago', 'IL', nil, "prints out correctly with striping out empty 'zip'", "123 Main St Apt #111 Chicago,IL"],
      ['123 Main St', 'Apt #111', 'Chicago', '', nil, "prints out correctly with striping out empty 'state' and 'zip'", "123 Main St Apt #111 Chicago"]
    ].each do |a_1, a_2, c, s, z, test, result|
      it '#{test}' do
        participant = FactoryGirl.build(:participant, address_line1: a_1, address_line2: a_2, city: c, state: s, zip: z)
        participant.address.should == "#{result}"
      end
    end

    it "returns nil for all nil or empty address field" do
      participant = FactoryGirl.build(:participant)
      participant.address.should == nil
    end
  end

  describe '#seach_display' do
    it "includes names" do
      participant = FactoryGirl.build(:participant,:first_name=>"Brian",:last_name=>"Lee")
      participant.search_display.should == "Brian Lee"
    end

    it "includes names and address" do
      participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345',:first_name=>"Brian",:last_name=>"Lee")
      participant.search_display.should == "Brian Lee - 123 Main St Apt #111 Chicago,IL 12345"
    end

    it "includes names, address and email" do
      participant = participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345', email: 'email@test.com',:first_name=>"Brian",:last_name=>"Lee")
      participant.search_display.should == "Brian Lee - 123 Main St Apt #111 Chicago,IL 12345 - email@test.com"
    end

    it "includes names" do
      participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345', email: 'email@test.com', primary_phone: '1234567890',:first_name=>"Brian",:last_name=>"Lee")
      participant.search_display.should == "Brian Lee - 123 Main St Apt #111 Chicago,IL 12345 - email@test.com - 1234567890"
    end
  end

  describe '#validates' do
    [
    '(123) 456 7899',
    '(123).456.7899',
    '(123)-456-7899',
    '123-456-7899',
    '123 456 7899',
    '1234567899',
    ].each do |phone|
      it "allows #{phone} as valid primary_phone" do
        participant = FactoryGirl.create(:participant, primary_phone: phone)
        participant.should be_valid
      end

      it "allows #{phone} as valid secondary_phone" do
        participant = FactoryGirl.create(:participant, secondary_phone: phone)
        participant.should be_valid
      end
    end

    it 'does not allow phone with alphabets as a valid primary_phone' do
      participant = FactoryGirl.build(:participant, primary_phone: '123ABC3456')
      participant.should_not be_valid
    end

    it 'does not allow phone with alphabets as a valid secondary_phone' do
      participant = FactoryGirl.build(:participant, secondary_phone: '123ABC3456')
      participant.should_not be_valid
    end
  end

  describe 'search scope' do
    it 'returns all the participant with first_name or last_name with "J"' do
      par1 = FactoryGirl.create(:participant, first_name: 'Jacob')
      par2 = FactoryGirl.create(:participant, last_name: 'jim')
      par3 = FactoryGirl.create(:participant)

      partcipants = Participant.search('j')
      partcipants.should include par1
      partcipants.should include par2
      partcipants.should_not include par3
    end
  end

  describe '#relationships' do
    before(:each) do
      sib1 = FactoryGirl.create(:participant, first_name: 'Jacob')
      sib2 = FactoryGirl.create(:participant)
      parent = FactoryGirl.create(:participant, first_name: 'Martha')

      @rel1 = FactoryGirl.create(:relationship, origin: sib1, destination: sib2)
      @rel2 = FactoryGirl.create(:relationship, category: 'parent', origin: parent, destination: sib1)
      @rel3 = FactoryGirl.create(:relationship, category: 'parent', origin: parent, destination: sib2)

      @relationships = sib1.relationships
    end

    it 'includes origin_relationships and destination_relationships' do
      @relationships.should include @rel1
      @relationships.should include @rel2
    end

    it 'does not include any other relationships' do
      @relationships.should_not include @rel3
    end
  end

  context 'proxy' do
    let(:account) { FactoryGirl.create(:account) }

    describe '#proxy?' do
      it "retruns true if account_participant has proxy" do
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        participant.proxy?.should be_true
      end

      it "retruns false if account_participant has proxy" do
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        participant.proxy?.should be_false
      end
    end
    describe '#adult_proxy?' do
      it "retruns true if account_participant has proxy and participant is not child" do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        participant.adult_proxy?.should be_true
      end

      it "retruns false if account_participant has proxy and participant is child" do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        participant.adult_proxy?.should be_false
      end

      it "retruns false if account_participant has no proxy and participant is child" do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        participant.adult_proxy?.should be_false
      end

      it "retruns false if account_participant has no proxy and participant is not child" do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        participant.adult_proxy?.should be_false
      end
    end

    describe '#child_proxy?' do
      it "retruns true if account_participant has proxy and participant is child" do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        participant.child_proxy?.should be_true
      end

      it "retruns false if account_participant has proxy and participant is not child" do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        participant.child_proxy?.should be_false
      end

      it "retruns false if account_participant has no proxy and participant is child" do
        participant.child = true
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        participant.child_proxy?.should be_false
      end

      it "retruns false if account_participant has no proxy and participant is not child" do
        participant.child = false
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        participant.child_proxy?.should be_false
      end
    end
  end

  describe '#on_study?' do
    let(:study) { FactoryGirl.create(:study,:state=>'active') }

    it 'returns true if participant has any study involvement with start date is in past and no end date' do
      FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 2.days.ago)
      participant.on_study?.should be_true
    end

    it 'returns true if participant has any study involvement with start date is in past and end date is in future' do
      FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 2.days.ago, end_date: 2.days.from_now)
      participant.on_study?.should be_true
    end

    it 'returns false if participant has any study involvement with start date is in future' do
      si = FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 2.days.from_now)
      participant.on_study?.should be_false
    end

    it 'returns false if participant has any study involvement with end date is in past' do
      FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 4.days.ago, end_date: 2.days.ago)
      participant.on_study?.should be_false
    end

    # By design we allow to participant to be added to the inactive study.
    it "should return true if association dates are within range and study is inactive" do
      study.state='inactive'
      study.save
      study.reload
      FactoryGirl.create(:study_involvement, participant: participant, study: study, start_date: 2.days.ago, end_date: 2.days.from_now)
      participant.on_study?.should be_true
    end
  end

  describe '#recent_response_set' do
    it "should return last updated_at response_set" do
      survey = FactoryGirl.create(:survey, :multiple_section=>true)
      res1 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res2 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res3 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res2.updated_at = Time.now + 10.minutes
      res2.save
      participant.recent_response_set.should == res2
    end
  end

  describe '#open?' do
    [:consent, :demographics, :surevey, :survey_started].each do |st|
      it "should return true if participant has state '#{st.to_s}'" do
        participant.stage = st
        participant.open?.should be_true
      end
    end
  end

  describe '#consented?' do
    [:demographics, :completed, :survey, :survey_started, :pending_approval, :enrolled].each do |st|
      it "should return true if participant has state '#{st.to_s}' and has consent" do
        FactoryGirl.create(:consent_signature, consent: FactoryGirl.create(:consent), participant: participant)
        participant.stage = st
        participant.consented?.should be_true
      end
    end

    [:demographics, :completed, :survey, :survey_started, :pending_approval, :enrolled].each do |st|
      it "should return false if participant has state '#{st.to_s}' but no consent" do
        participant.stage = st
        participant.consented?.should be_false
      end
    end
  end

  describe '#completed?' do
    [:pending_approval, :enrolled].each do |st|
      it "should return true if participant has state '#{st.to_s}'" do
        participant.stage = st
        participant.completed?.should be_true
      end
    end
  end

  describe '#inactive?' do
    [:new, :consent, :demographics].each do |st|
      it "should return true if participant has state '#{st.to_s}'" do
        participant.stage = st
        participant.inactive?.should be_true
      end
    end
  end

  describe '#copy_from' do
    let(:other) { FactoryGirl.create(:participant, address_line1: '123 Main St', address_line2: 'Apt #123', city: 'Chicago',
      state: 'IL', zip: '12345', email: 'test@test.com', primary_phone: '123-456-7890', secondary_phone: '123-345-6789')}

    before(:each) do
      participant.copy_from(other)
    end

    it "copies 'address_line1' from other participant" do
      participant.address_line1.should == other.address_line1
    end

    it "copies 'address_line2' from other participant" do
      participant.address_line2.should == other.address_line2
    end

    it "copies 'city' from other participant" do
      participant.city.should == other.city
    end

    it "copies 'state' from other participant" do
      participant.state.should == other.state
    end

    it "copies 'zip' from other participant" do
      participant.zip.should == other.zip
    end

    it "copies 'email' from other participant" do
      participant.email.should == other.email
    end

    it "copies 'primary_phone' from other participant" do
      participant.primary_phone.should == other.primary_phone
    end

    it "copies 'secondary_phone' from other participant" do
      participant.secondary_phone.should == other.secondary_phone
    end
  end
end






















































