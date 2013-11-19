require 'spec_helper'

describe Question do
  before(:each) do
    @survey = FactoryGirl.create(:survey,:multiple_section=>true)
    @section = @survey.sections.create(:title=>"test")
  end

  it "should now allow answers for response_types other than multiple choice" do 
    ["date","number","long_text","short_text","label"].each_with_index do |response_type,i|
      question = @section.questions.create(:text=>"test#{i}",:section_id=>@section.id,:response_type=>"pick_many")
      answer = question.answers.create(:text=>"test",:question=>@question)
      question.response_type=response_type
      question.save
      question.should_not be_valid
      question.should have_at_least(1).error_on(:type)
    end
  end

  it "should not allow duplicate codes accross sections" do 
    section2 = @survey.sections.create(:title=>"test2")
    question = @section.questions.create(:text=>"test1",:response_type=>"pick_many",:code=>"q_2")
    question2 = section2.questions.create(:text=>"test2",:response_type=>"pick_many",:code=>"q_2")
    question2.should_not be_valid
    question2.should have_at_least(1).error_on(:code)
  end


  
end
