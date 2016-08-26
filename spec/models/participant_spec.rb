require 'rails_helper'

RSpec.describe Participant, type: :model do
  let(:participant) { FactoryGirl.create(:participant) }
  let(:account) { FactoryGirl.create(:account) }

  it 'creates a new instance given valid attributes' do
    expect(participant).not_to be_nil
  end

  it { is_expected.to have_many(:origin_relationships) }
  it { is_expected.to have_many(:destination_relationships) }
  it { is_expected.to have_many(:study_involvements) }
  it { is_expected.to have_many(:contact_logs) }
  it { is_expected.to validate_length_of(:zip).is_at_most(5) }
  it { is_expected.to validate_numericality_of(:zip) }

  describe 'validations' do
    describe 'phone' do
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
  end

  describe 'scopes' do
    before(:each) do
      Participant.aasm.states.map(&:name).each do |state|
        FactoryGirl.create(:participant, stage: state)
      end
    end

    it 'allows to search by stage' do
      Participant.aasm.states.map(&:name).each do |state|
        participants = Participant.by_stage(state)
        expect(participants.size).to eq 1

        participants.each do |participant|
          expect(participant.stage).to eq state.to_s
        end
      end
    end

    it 'allows to search for participants with pending approval' do
      participants = Participant.pending_approval
      expect(participants.size).to eq 1

      participants.each do |participant|
        expect(participant.stage).to eq 'pending_approval'
      end
    end

    it 'allows to search for approved participants' do
      participants = Participant.approved
      expect(participants.size).to eq 1

      participants.each do |participant|
        expect(participant.stage).to eq 'approved'
      end
    end

    it 'allows to search for suspended participants' do
      participants = Participant.suspended
      expect(participants.size).to eq 1

      participants.each do |participant|
        expect(participant.stage).to eq 'suspended'
      end
    end

    describe 'searching for participants approaching deadlines' do
      before :each do
        @enrolled_participant = FactoryGirl.create(:participant, stage: 'approved')
        @study_involvement    = FactoryGirl.create(:study_involvement, participant: @enrolled_participant, warning_date: nil, end_date: Date.tomorrow)
      end

      it 'includes approved participants with undefined enrollment warninng date and end date set in future' do
        expect(Participant.approaching_deadlines).to match_array([@enrolled_participant])
      end

      it 'excludes not aproved participants' do
        Participant.aasm.states.map(&:name).each do |state|
          unless state.to_s == 'approved'
            @enrolled_participant.stage = state
            @enrolled_participant.save!
            expect(Participant.approaching_deadlines).to be_empty
          end
        end
      end

      it 'excludes participants with blank sudy involvement start date' do
        @study_involvement.start_date = nil
        @study_involvement.save!(validate: false)

        expect(Participant.approaching_deadlines).to be_empty
      end

      it 'includes participants with sudy involvement warning date in the past' do
        @study_involvement.warning_date = Date.today - 1.day
        @study_involvement.save!

        expect(Participant.approaching_deadlines).to match_array([@enrolled_participant])
      end


      it 'excludes participants with sudy involvement warning date in the future' do
        @study_involvement.warning_date = Date.today + 1.day
        @study_involvement.save!

        expect(Participant.approaching_deadlines).to be_empty
      end

      it 'excludes participants with sudy involvement end date in the past' do
        @study_involvement.end_date = Date.today - 1.day
        @study_involvement.save!

        expect(Participant.approaching_deadlines).to be_empty
      end

      it 'includes participants with blank sudy involvement end date' do
        @study_involvement.end_date = nil
        @study_involvement.save!(validate: false)

        expect(Participant.approaching_deadlines).to match_array([@enrolled_participant])
      end
    end

    it 'allows to search for all participants' do
      participants = Participant.all_participants
      expect(participants.size).to eq 2

      participants.each do |participant|
        expect(['approved', 'pending_approval']).to include(participant.stage)
      end
    end

    it 'allows to search by first_name or last_name' do
      par1 = FactoryGirl.create(:participant, first_name: 'Jacob')
      par2 = FactoryGirl.create(:participant, last_name: 'jim')
      par3 = FactoryGirl.create(:participant, first_name: 'My', last_name: 'Little')

      partcipants = Participant.search('j')
      expect(partcipants).not_to be_empty
      partcipants.all.each do |participant|
        expect(participant.name).to match /j/i
      end
    end
  end

  describe 'methods' do
    it 'returns filled states' do
      expect(participant.filled_states).to eq [:consent, :demographics, :survey]
    end

    describe '#name' do
      it 'joins first name and last name' do
        participant = FactoryGirl.build(:participant, first_name: 'Brian', last_name: 'Lee')
        expect(participant.name).to eq 'Brian Lee'
      end
    end

    it 'returns relationships as both origin_relationships and destination_relationships' do
      sib1 = FactoryGirl.create(:participant, first_name: 'Jacob')
      sib2 = FactoryGirl.create(:participant)
      parent = FactoryGirl.create(:participant, first_name: 'Martha')

      @rel1 = FactoryGirl.create(:relationship, origin: sib1, destination: sib2)
      @rel2 = FactoryGirl.create(:relationship, category: 'Parent', origin: parent, destination: sib1)
      @rel3 = FactoryGirl.create(:relationship, category: 'Parent', origin: parent, destination: sib2)

      @relationships = sib1.relationships

      expect(@relationships).to match_array([@rel1, @rel2])
    end

    it 'checks if participant has relationships' do
      child = FactoryGirl.create(:participant, first_name: 'Jacob')
      parent = FactoryGirl.create(:participant, first_name: 'Martha')

      expect(parent).not_to have_relationships

      relationship = FactoryGirl.create(:relationship, category: 'Parent', origin: parent, destination: child)
      expect(parent.reload).to have_relationships
    end

    describe 'has_followup_survey?' do
      it 'should return false if participant has child survey' do
        survey = FactoryGirl.create(:survey, multiple_section: true, code: 'child')
        FactoryGirl.create(:response_set, participant: participant, survey: survey)
        expect(participant).not_to have_followup_survey
      end
    end

    describe 'address' do
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

    describe 'on_study?' do
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

    it 'checks if participant is on a study' do
      study = FactoryGirl.create(:study, state: 'active')
      study_involvement = FactoryGirl.create(:study_involvement, participant: participant)

      expect(participant).to have_study(study_involvement.study)
      expect(participant).not_to have_study(study)
    end

    describe 'seach_display' do
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

    it 'allows to create a new response set for a survey' do
      survey = FactoryGirl.create(:survey)
      expect{ participant.create_response_set(survey) }.to change{ ResponseSet.count }.by(1)
    end

    describe 'adult_proxy?' do
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

    describe 'child_proxy?' do
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

    describe 'proxy?' do
      it 'retruns true if account_participant has proxy' do
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: true)
        expect(participant).to be_proxy
      end

      it 'retruns false if account_participant has proxy' do
        FactoryGirl.create(:account_participant, participant: participant, account: account, proxy: false)
        expect(participant).not_to be_proxy
      end
    end

    describe 'open?' do
      Participant.aasm.states.map(&:name).each do |state|
        if [:consent, :demographics, :survey].include? state
          it "should return true if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).to be_open
          end
        else
          it "should return false if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).not_to be_open
          end
        end
      end
    end

    describe 'consented?' do
      Participant.aasm.states.map(&:name).each do |state|
        if [:demographics, :completed, :survey, :pending_approval, :approved].include? state
          it "should return true if participant has state '#{state.to_s}' and has consent" do
            FactoryGirl.create(:consent_signature, consent: FactoryGirl.create(:consent), participant: participant)
            participant.stage = state
            expect(participant).to be_consented
          end

          it "should return false if participant has state '#{state.to_s}' but no consent" do
            participant.stage = state
            expect(participant).not_to be_consented
          end
        else
          it "should return false if participant has state '#{state.to_s}' and has consent" do
            FactoryGirl.create(:consent_signature, consent: FactoryGirl.create(:consent), participant: participant)
            participant.stage = state
            expect(participant).not_to be_consented
          end

          it "should return false if participant has state '#{state.to_s}' and no consent" do
            participant.stage = state
            expect(participant).not_to be_consented
          end
        end
      end
    end

    describe 'completed?' do
      Participant.aasm.states.map(&:name).each do |state|
        if [:pending_approval, :approved].include? state
          it "should return true if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).to be_completed
          end
        else
          it "should return false if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).not_to be_completed
          end
        end
      end
    end

    describe 'inactive?' do
      Participant.aasm.states.map(&:name).each do |state|
        if [:consent, :demographics, :consent_denied].include? state
          it "should return true if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).to be_inactive
          end
        else
          it "should return false if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).not_to be_inactive
          end
        end
      end
    end

    describe 'active?' do
      Participant.aasm.states.map(&:name).each do |state|
        if [:survey, :pending_approval, :approved].include? state
          it "should return true if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).to be_active
          end
        else
          it "should return false if participant has state '#{state.to_s}'" do
            participant.stage = state
            expect(participant).not_to be_active
          end
        end
      end
    end

    it 'should return last response_set' do
      survey = FactoryGirl.create(:survey, multiple_section: true)
      res1 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res2 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res3 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
      res2.updated_at = Time.now + 10.minutes
      res2.save
      expect(participant.recent_response_set).to eq res2
    end

    describe 'recent_core_response_set' do
      it 'should return last "child" survey response_set for a child participant' do
        child_survey = FactoryGirl.create(:survey, multiple_section: true, code: 'child')
        adult_survey = FactoryGirl.create(:survey, multiple_section: true, code: 'adult')
        survey       = FactoryGirl.create(:survey, multiple_section: true)
        res1 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
        res2 = FactoryGirl.create(:response_set, participant: participant, survey: child_survey)
        res3 = FactoryGirl.create(:response_set, participant: participant, survey: adult_survey)
        res4 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
        res5 = FactoryGirl.create(:response_set, participant: participant, survey: child_survey)
        res6 = FactoryGirl.create(:response_set, participant: participant, survey: adult_survey)
        participant.child = true

        expect(participant.recent_core_response_set).to eq res5
      end

      it 'should return last "adult" survey response_set for an adult participant' do
        child_survey = FactoryGirl.create(:survey, multiple_section: true, code: 'child')
        adult_survey = FactoryGirl.create(:survey, multiple_section: true, code: 'adult')
        survey       = FactoryGirl.create(:survey, multiple_section: true)
        res1 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
        res2 = FactoryGirl.create(:response_set, participant: participant, survey: child_survey)
        res3 = FactoryGirl.create(:response_set, participant: participant, survey: adult_survey)
        res4 = FactoryGirl.create(:response_set, participant: participant, survey: survey)
        res5 = FactoryGirl.create(:response_set, participant: participant, survey: child_survey)
        res6 = FactoryGirl.create(:response_set, participant: participant, survey: adult_survey)

        expect(participant.recent_core_response_set).to eq res6
      end
    end

    it 'returns related active participants' do
      FactoryGirl.create(:account_participant, participant: participant, account: account)
      Participant.aasm.states.map(&:name).each do |state|
        other_participant = FactoryGirl.create(:participant, stage: state)
        FactoryGirl.create(:account_participant, participant: other_participant, account: account)
      end

      related_participants = participant.related_participants
      expect(related_participants).not_to be_empty
      related_participants.each do |related_participant|
        expect(related_participant).to be_active
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

end
