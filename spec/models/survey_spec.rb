require 'spec_helper'

describe Survey do
  before(:each) do
  end


  it "should create section for surveys that are not multiple sections" do 
    survey = FactoryGirl.create(:survey,:multiple_section=>false)
    survey.sections.size.should eq(1)
  end

  
end
