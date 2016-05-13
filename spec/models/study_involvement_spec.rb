require 'spec_helper'

describe StudyInvolvement do
  it { is_expected.to have_one :study_involvement_status }
  it { is_expected.to validate_presence_of :start_date }
  it { is_expected.to validate_presence_of :participant}
  it { is_expected.to validate_presence_of :study }
  it { is_expected.to be_versioned }

  let(:study_involvement) { FactoryGirl.create(:study_involvement) }
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

    it 'can be nil' do
      study_involvement = FactoryGirl.build(:study_involvement, end_date: date)
      expect(study_involvement).to be_valid
    end
  end

  describe 'scope active' do
    before(:each) do
      date = Date.today
      @si1 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date + 1.days)
      @si2 = FactoryGirl.create(:study_involvement, start_date: date - 10.days, end_date: date)
      @si3 = FactoryGirl.create(:study_involvement, start_date: date - 20.days, end_date: date - 15.days)

      @study_involvements = StudyInvolvement.active
    end

    it 'should include study involvement whose end date is in future' do
      expect(@study_involvements).to include @si1
    end

    it 'should include study involvement whose end date is today' do
      expect(@study_involvements).to include @si2
    end

    it 'should not include study involvement whose end date is in past' do
      expect(@study_involvements).not_to include @si3
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
end