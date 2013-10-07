require 'spec_helper'

describe StudyInvolvement do
  let(:study_involvement) { FactoryGirl.create(:study_involvement) }
  it "creates a new instance given valid attributes" do
    study_involvement.should_not be_nil
  end
  
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :participant}
  it { should validate_presence_of :study }
end