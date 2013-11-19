require 'spec_helper'

describe Section do
  before(:each) do
  end

  it "should not allow more than one section where multiple section is false" do 
    survey = FactoryGirl.create(:survey,:multiple_section=>false) 
    survey.sections.size.should == 1
    survey.reload
    section = survey.sections.create(:title=>"test")
    survey.reload
    survey.sections.size.should == 1
    section.should_not be_valid
    section.should have_at_least(1).error_on(:survey_id)
  end
  
end
