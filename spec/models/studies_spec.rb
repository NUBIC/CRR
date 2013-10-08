require 'spec_helper'

describe Study do
  let(:date) { Date.new(2013, 10, 10) }
  
  it "creates a new instance given valid attributes" do
    study = FactoryGirl.create(:study)
    study.should_not be_nil
  end

  it { should validate_presence_of :active_on }
  it { should have_many(:study_involvements) }

  describe 'validates inactive_on' do
    it 'should not be before active_on' do
      study = FactoryGirl.build(:study, active_on: date, inactive_on: date - 1.days)
      study.should_not be_valid
      study.should have(1).error_on(:inactive_on)
      study.errors[:inactive_on].should == ["can't be before active_on"]
    end

    it 'should be after active_on' do
      study = FactoryGirl.build(:study, active_on: date, inactive_on: date + 1.days)
      study.should be_valid
    end

    it 'can be nil' do
      study = FactoryGirl.build(:study, active_on: date)
      study.should be_valid
    end
  end

  # describe 'active scope' do
  #   it 'includes study which has past active date and does not have inactive date' do
  #     study = FactoryGirl.create(:study, active_on: date - 1.days)
  #     studies = Study.active

  #     studies.should include study
  #   end

  #   it 'includes study which has past active date and has future inactive date' do
  #     study = FactoryGirl.create(:study, active_on: date - 1.days, inactive_on: date + 1.days)
  #     studies = Study.active

  #     studies.should include study
  #   end

  #   it 'does not include study which has future active date' do
  #     study = FactoryGirl.create(:study, active_on: date + 1.days)
  #     studies = Study.active

  #     studies.count.should == 0
  #     studies.should_not include study
  #   end

  #   it 'does not include study who has future active and inactive dates' do
  #     study = FactoryGirl.create(:study, active_on: date + 1.days, inactive_on: date + 4.days)
  #     studies = Study.active

  #     studies.count.should == 0
  #     studies.should_not include study
  #   end

  #   it "does not include study who has past active and inactive dates" do
  #     study = FactoryGirl.create(:study, active_on: date - 2.days, inactive_on: date - 1.days)
  #     studies = Study.active

  #     studies.count.should == 0
  #     studies.should_not include study
  #   end
  # end
end
