# == Schema Information
#
# Table name: answers
#
#  id            :integer          not null, primary key
#  question_id   :integer
#  text          :text
#  help_text     :text
#  display_order :integer
#  code          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe Answer do

  before(:each) do 
    @survey = FactoryGirl.create(:survey,:multiple_section=>true)
    @section = @survey.sections.create(:title=>"title")
    @question = @section.questions.create(:text=>"hello",:response_type=>"pick_many")
  end

  it "ensures that all the answers on a question have a unique display_order attribute" do
    first_answer = @question.answers.create(:question_id => @question.id, :display_order => 0, :text => "Answer #1")
    
    second_answer = Answer.new(:question_id => @question.id, :display_order => 0, :text => "Answer #2",:code=>"a_2")
    second_answer.valid?.should be_false
    lambda { second_answer.save! }.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Display order has already been taken")
    
    second_answer.display_order = 1
    second_answer.valid?.should be_true
    lambda { second_answer.save! }.should_not raise_error
    
    second_answer.display_order = 0
    second_answer.valid?.should be_false
    lambda { second_answer.save! }.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Display order has already been taken")
  end

  it "should not allow answer for wrong display type" do 
    ["date","number","long_text","short_text","label"].each do |response_type|
      @question.update_attribute(:response_type,response_type)
      answer = @question.answers.new(:question_id=>@question.id,:text=>"test")
      answer.should_not be_valid
      answer.should have_at_least(1).error_on(:question)
    end


  end
   
end
