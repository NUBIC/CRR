require 'spec_helper'

describe StudyInvolvement do
  it { is_expected.to belong_to :study }
  it { is_expected.to belong_to :participant }
  it { is_expected.to have_one :study_involvement_status }
  it { is_expected.to have_one :search_participant_study_involvement }
  it { is_expected.to have_one :search_participant }

  it { is_expected.to validate_presence_of :start_date }
  it { is_expected.to validate_presence_of :end_date }
  it { is_expected.to validate_presence_of :participant}
  it { is_expected.to validate_presence_of :study }
  it { is_expected.to be_versioned }

  let(:study) { FactoryGirl.create(:study) }
  let(:participant) { FactoryGirl.create(:participant) }
  let(:study_involvement) { FactoryGirl.create(:study_involvement, participant: participant, study: study) }
  let(:date) { Date.new(2013, 10, 10) }

  it 'creates a new instance given valid attributes' do
    expect(study_involvement).not_to be_nil
  end

  describe 'validates end_date' do
    it 'should not be before start_date' do
      study_involvement = FactoryGirl.build(:study_involvement, start_date: date, end_date: date - 1.days)
      expect(study_involvement).not_to be_valid
      expect(study_involvement.errors[:end_date]).not_to be_empty
      expect(study_involvement.errors[:end_date]).to include 'can\'t be before start_date'
    end

    it 'should be after start_date' do
      study_involvement = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
      expect(study_involvement).to be_valid
    end
  end

  describe 'validating participant enrollment' do
    it 'should not allow to enroll participant twice in the same study' do
      study_involvement = FactoryGirl.create(:study_involvement, participant: participant, study: study)
      new_study_involvement = StudyInvolvement.new(participant: participant, study: study, start_date: date - 10.days, end_date: date + 1.days)
      expect(new_study_involvement).not_to be_valid
      expect(new_study_involvement.errors.full_messages).to include 'Participant had already been released to the study. If extension is needed please indicate by checking the flag below.'
    end

    it 'should allow to create extended participant enrollment' do
      study_involvement = FactoryGirl.create(:study_involvement, participant: participant, study: study)
      new_study_involvement = FactoryGirl.create(:study_involvement, participant: participant, study: study, extended_release: true)
      expect(new_study_involvement).to be_valid
    end
  end

  describe 'scopes:' do
    it 'active scope should return qualifying study involvements' do
      date = Date.today
      si1 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date + 1.days)
      si2 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date)
      si3 = FactoryGirl.create(:study_involvement, start_date: date - 20.days, end_date: date - 15.days)
      si4 = FactoryGirl.create(:study_involvement, start_date: date + 1.days, end_date: date + 10.days)
      expect(StudyInvolvement.active).to match_array([si1, si2])
    end

    it 'warning scope returns qualifying study involvements' do
      date = Date.today
      si1 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date + 10.days)
      si2 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date + 10.days, warning_date: date)
      si3 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date + 10.days, warning_date: date + 3.days)
      si4 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date + 10.days, warning_date: date - 3.days)
      si5 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date - 2.days, warning_date: date - 3.days)
      expect(StudyInvolvement.warning).to match_array([si2, si4])
    end

    it 'approved scope returns qualifying study involvements' do
      date = Date.today
      si1 = FactoryGirl.create(:study_involvement)
      si2 = FactoryGirl.create(:study_involvement)
      si3 = FactoryGirl.create(:study_involvement)
      FactoryGirl.create(:study_involvement_status, study_involvement: si2)
      FactoryGirl.create(:study_involvement_status, study_involvement: si3).approve!
      expect(StudyInvolvement.approved).to match_array([si3])
    end

    it 'pending scope returns qualifying study involvements' do
      date = Date.today
      si1 = FactoryGirl.create(:study_involvement)
      si2 = FactoryGirl.create(:study_involvement)
      si3 = FactoryGirl.create(:study_involvement)
      FactoryGirl.create(:study_involvement_status, study_involvement: si2)
      FactoryGirl.create(:study_involvement_status, study_involvement: si3).approve!
      expect(StudyInvolvement.pending).to match_array([si2])
    end
  end

  describe 'active?' do
    it 'should be true if end date is today' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today)
      expect(study_involvement).to be_active
    end

    it 'should be true if end date is in future' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today + 10.days)
      expect(study_involvement).to be_active
    end

    it 'should be false if end date is in past' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today - 10.days)
      expect(study_involvement).not_to be_active
    end
  end

  describe 'inactive?' do
    it 'should be false if end date is today' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today)
      expect(study_involvement).not_to be_inactive
    end

    it 'should be false if end date is in future' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today + 10.days)
      expect(study_involvement).not_to be_inactive
    end

    it 'should be trie if end date is in past' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today - 10.days)
      expect(study_involvement).to be_inactive
    end
  end

  describe 'original_release?' do
    it 'returns true for study_involvements without extended_release flag' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today)
      expect(study_involvement).to be_original_release
    end

    it 'returns true for study_involvements with extended_release flag set to false' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today, extended_release: false)
      expect(study_involvement).to be_original_release
    end

    it 'returns false for study_involvements with extended_release flag set to true' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today, extended_release: true)
      expect(study_involvement).not_to be_original_release
    end
  end

  describe 'extended_release?' do
    it 'returns false for study_involvements without extended_release flag' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today)
      expect(study_involvement).not_to be_extended_release
    end

    it 'returns false for study_involvements with extended_release flag set to false' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today, extended_release: false)
      expect(study_involvement).not_to be_extended_release
    end

    it 'returns true for study_involvements with extended_release flag set to true' do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today, extended_release: true)
      expect(study_involvement).to be_extended_release
    end
  end

  describe 'getting study_involvement status' do
    it 'returns "None" if none exists' do
      study_involvement = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
      expect(study_involvement.status).to eq 'None'
    end

    it 'returns status state if status is not yet approved' do
      study_involvement         = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
      study_involvement_status  = FactoryGirl.create(:study_involvement_status, study_involvement: study_involvement)
      expect(study_involvement.status).to eq study_involvement_status.state.titleize
    end

    it 'returns status name if status is approved' do
      study_involvement         = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
      study_involvement_status  = FactoryGirl.create(:study_involvement_status, study_involvement: study_involvement)
      study_involvement_status.approve!
      expect(study_involvement.status).to eq study_involvement_status.name.titleize
    end
  end

  describe 'setting study_involvement status' do
    describe 'with valid attributes' do
      it 'creates a status if not exists' do
        study_involvement         = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
        expect(study_involvement.study_involvement_status).to be_blank

        status = StudyInvolvementStatus.valid_statuses.map{|s| s[:name]}.sample
        study_involvement.status  = status
        study_involvement.save

        expect(study_involvement.study_involvement_status).not_to be_blank
        expect(study_involvement.study_involvement_status).to be_a StudyInvolvementStatus
        expect(study_involvement.study_involvement_status.name).to eq status
      end

      it 'updates status if exists' do
        statuses = StudyInvolvementStatus.valid_statuses.map{|s| s[:name]}.sample(2)
        study_involvement         = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
        study_involvement.status  = statuses.first
        study_involvement.save

        study_involvement.status  = statuses.last
        study_involvement.save
        expect(study_involvement.study_involvement_status).not_to be_blank
        expect(study_involvement.study_involvement_status).to be_a StudyInvolvementStatus
        expect(study_involvement.study_involvement_status.name).to eq statuses.last
      end
    end

    it 'raises validation error with invalid attributes' do
      study_involvement         = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
      status = StudyInvolvementStatus.valid_statuses.map{|s| s[:name]}.sample + 'blahblah'
      study_involvement.status  = status
      expect { study_involvement.save! }.to raise_error(ActiveRecord::RecordInvalid).with_message('Validation failed: Study involvement status name is not included in the list')
    end
  end
end