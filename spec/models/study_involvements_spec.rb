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
end