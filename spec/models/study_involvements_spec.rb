require 'spec_helper'

describe StudyInvolvement do
  let(:study_involvement) { FactoryGirl.create(:study_involvement) }
  let(:date) { Date.new(2013, 10, 10) }
  it "creates a new instance given valid attributes" do
    study_involvement.should_not be_nil
  end

  it { should validate_presence_of :start_date }
  it { should validate_presence_of :participant}
  it { should validate_presence_of :study }

  describe 'validates end_date' do
    it 'should not be before start_date' do
      study_involvement = FactoryGirl.build(:study_involvement, start_date: date, end_date: date - 1.days)
      study_involvement.should_not be_valid
      study_involvement.should have(1).error_on(:end_date)
      study_involvement.errors[:end_date].should == ["can't be before start_date"]
    end

    it 'should be after start_date' do
      study_involvement = FactoryGirl.build(:study_involvement, start_date: date, end_date: date + 1.days)
      study_involvement.should be_valid
    end

    it 'can be nil' do
      study_involvement = FactoryGirl.build(:study_involvement, end_date: date)
      study_involvement.should be_valid
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

    it "should include study involvement whose end date is in future" do
      @study_involvements.should include @si1
    end

    it "should include study involvement whose end date is today" do
      @study_involvements.should include @si2
    end

    it "should not include study involvement whose end date is in past" do
      @study_involvements.should_not include @si3
    end
  end

  describe 'active?' do

    it "should be true if end date is today" do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today)
      study_involvement.active?.should be_true
    end

    it "should be true if end date is in future" do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today + 10.days)
      study_involvement.active?.should be_true
    end

    it "should be false if end date is in past" do
      study_involvement = FactoryGirl.create(:study_involvement, end_date: Date.today - 10.days)
      study_involvement.active?.should be_false
    end
  end
end