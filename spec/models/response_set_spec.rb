require 'spec_helper'

describe ResponseSet do
  before(:each) do
    @participant = FactoryGirl.create(:participant)
    @survey = FactoryGirl.create(:survey,:multiple_section=>true)
    @section = @survey.sections.create(:title=>"test")
    @q_pick_many = @section.questions.create(:text=>"test",:response_type=>"pick_many",:is_mandatory=>true,:code=>"q_many")
    @q_pick_one = @section.questions.create(:text=>"test2",:response_type=>"pick_one",:is_mandatory=>true,:code=>"q_one")
    @q_number = @section.questions.create(:text=>"test2",:response_type=>"number",:is_mandatory=>true,:code=>"q_number")
    @q_date = @section.questions.create(:text=>"test2",:response_type=>"date",:is_mandatory=>true)
    @q_short_text = @section.questions.create(:text=>"test2",:response_type=>"short_text",:is_mandatory=>true)
    @q_long_text = @section.questions.create(:text=>"test2",:response_type=>"long_text",:is_mandatory=>true)
    @response_set = @participant.response_sets.create(:survey_id=>@survey.id)  
    @pm_a1 = @q_pick_many.answers.create(:text=>"one")
    @pm_a2 = @q_pick_many.answers.create(:text=>"two")
    @pm_a3 = @q_pick_many.answers.create(:text=>"three")
    @pm_a4 = @q_pick_many.answers.create(:text=>"four")
    @po_a1 = @q_pick_one.answers.create(:text=>"red")
    @po_a2 = @q_pick_one.answers.create(:text=>"blue")
    @po_a3 = @q_pick_one.answers.create(:text=>"green")
    @po_a4 = @q_pick_one.answers.create(:text=>"orange")
  end


  it "should create getter setters that correspond to questions in survey" do
    @response_set.should respond_to("q_#{@q_pick_many.id}".to_sym)
    @response_set.should respond_to("q_#{@q_pick_many.id}=".to_sym)
  end

  it "should accept values for pick many" do 
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym=>["#{@pm_a1.id}","#{@pm_a2.id}"])
    @response_set.reload.responses.size.should == 2
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id).size.should == 2
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id,:answer_id=>@pm_a1.id).size.should == 1
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id,:answer_id=>@pm_a2.id).size.should == 1
  end

  it "should properly replace value for pick many" do 
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym=>["#{@pm_a1.id}","#{@pm_a2.id}"])
    @response_set.reload.responses.size.should == 2
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id).size.should == 2
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id,:answer_id=>@pm_a1.id).size.should == 1
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id,:answer_id=>@pm_a2.id).size.should == 1
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym=>["#{@pm_a3.id}","#{@pm_a4.id}"])
    @response_set.reload.responses.size.should == 2
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id).size.should == 2
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id,:answer_id=>@pm_a3.id).size.should == 1
    @response_set.reload.responses.where(:question_id=>@q_pick_many.id,:answer_id=>@pm_a4.id).size.should == 1
  end

  it "pick many should reject answers with the wrong question id" do 
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym=>["#{@po_a1.id}","#{@po_a2.id}"])
    @response_set.reload.responses.size.should == 0
  end

  it "should properly erase value for pick many" do 
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym=>["#{@pm_a1.id}","#{@pm_a2.id}"])
    @response_set.reload.responses.size.should == 2
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym=>[])
    @response_set.reload.responses.size.should == 0
  end

  it "should insert values for pick one" do 
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym=>"#{@po_a1.id}")
    @response_set.reload.responses.size.should == 1
    @response_set.reload.responses.where(:question_id=>@q_pick_one.id,:answer_id=>@po_a1.id).size.should == 1
  end

  it "should insert different value for pick one" do 
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym=>"#{@po_a1.id}")
    @response_set.reload.responses.size.should == 1
    @response_set.reload.responses.where(:question_id=>@q_pick_one.id,:answer_id=>@po_a1.id).size.should == 1
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym=>"#{@po_a2.id}")
    @response_set.reload.responses.size.should == 1
    @response_set.reload.responses.where(:question_id=>@q_pick_one.id,:answer_id=>@po_a2.id).size.should == 1
  end

  it "should erase values for pick one" do 
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym=>"#{@po_a1.id}")
    @response_set.reload.responses.size.should == 1
    @response_set.reload.responses.where(:question_id=>@q_pick_one.id,:answer_id=>@po_a1.id).size.should == 1
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym=>"")
    @response_set.reload.responses.size.should == 0
  end
  it "pick one should reject answers with the wrong question id" do 
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym=>"#{@pm_a1.id}")
    @response_set.reload.responses.size.should == 0
  end

  it "should insert value for date" do 
    @response_set.update_attributes("q_#{@q_date.id}".to_sym=>"12/12/2013")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_date.id}".to_sym).to_s.should == "12/12/2013"
  end

  it "should properly erase value for date" do 
    @response_set.update_attributes("q_#{@q_date.id}".to_sym=>"12/12/2013")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_date.id}".to_sym).to_s.should == "12/12/2013"
    @response_set.update_attributes("q_#{@q_date.id}".to_sym=>"")
    @response_set.reload.responses.size.should == 0
    @response_set.send("q_#{@q_date.id}".to_sym).to_s.should be_blank
  end

  it "should not insert bad value for date" do 
    @response_set.update_attributes("q_#{@q_date.id}".to_sym=>"44/44/2098")
    @response_set.reload.responses.size.should == 0
    @response_set.send("q_#{@q_date.id}".to_sym).to_s.should be_blank
  end

  it "should not overwrite previously inserted value when bad value is entered for date" do 
    @response_set.update_attributes("q_#{@q_date.id}".to_sym=>"12/12/2013")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_date.id}".to_sym).to_s.should == "12/12/2013"
    @response_set.update_attributes("q_#{@q_date.id}".to_sym=>"54/23/2134")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_date.id}".to_sym).to_s.should == "12/12/2013"

  end

  it "should insert value for short_text" do 
    @response_set.update_attributes("q_#{@q_short_text.id}".to_sym=>"we are in the business of shoting hoops")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_short_text.id}".to_sym).to_s.should == "we are in the business of shoting hoops"
  end

  it "should properly erase value for short_text" do 
    @response_set.update_attributes("q_#{@q_short_text.id}".to_sym=>"we are in the business of shoting hoops")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_short_text.id}".to_sym).to_s.should == "we are in the business of shoting hoops"
    @response_set.update_attributes("q_#{@q_short_text.id}".to_sym=>"")
    @response_set.reload.responses.size.should == 0
    @response_set.send("q_#{@q_short_text.id}".to_sym).to_s.should be_blank
  end
  it "should insert value for long_text" do 
    text = Faker::Lorem.paragraph
    @response_set.update_attributes("q_#{@q_long_text.id}".to_sym=>text)
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_long_text.id}".to_sym).to_s.should == text
  end

  it "should properly erase value for short_text" do 
    text = Faker::Lorem.paragraph
    @response_set.update_attributes("q_#{@q_long_text.id}".to_sym=>text)
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_long_text.id}".to_sym).to_s.should == text
    @response_set.update_attributes("q_#{@q_long_text.id}".to_sym=>"")
    @response_set.reload.responses.size.should == 0
    @response_set.send("q_#{@q_long_text.id}".to_sym).to_s.should be_blank
  end

  it "should insert value for number" do 
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"3456")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_number.id}".to_sym).to_s.should == "3456"
  end


  it "should not insert bad value for number" do 
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"3456fadsfd")
    @response_set.reload.responses.size.should == 0
    @response_set.send("q_#{@q_number.id}".to_sym).to_s.should be_blank
  end

  it "should not erase previously inserted number when bad number is provided" do 
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"3456")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_number.id}".to_sym).to_s.should == "3456"
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"3456fadsfdf")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_number.id}".to_sym).to_s.should == "3456"
  end

  it "should erase value for number" do 
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"3456")
    @response_set.reload.responses.size.should == 1
    @response_set.send("q_#{@q_number.id}".to_sym).to_s.should == "3456"
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"")
    @response_set.reload.responses.size.should == 0
    @response_set.send("q_#{@q_number.id}".to_sym).to_s.should be_blank
  end


  it "should not complete a survey that doesn't have it's mandatory sections complete" do 
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"3456")
    @response_set.reload.responses.size.should == 1
    @response_set.complete!.should be_false
    @response_set.reload.complete?.should be_false
  end

  it "should complete a survey that has all responses complete" do 
    @response_set.update_attributes("q_#{@q_number.id}".to_sym=>"3456")
    @response_set.update_attributes("q_#{@q_short_text.id}".to_sym=>"3456")
    @response_set.update_attributes("q_#{@q_long_text.id}".to_sym=>"3456")
    @response_set.update_attributes("q_#{@q_date.id}".to_sym=>"12/12/2012")
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym=>"#{@po_a1.id}")
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym=>["#{@pm_a1.id}"])
    @response_set.reload.responses.size.should == 6
    @response_set.complete!.should be_true
    @response_set.reload.complete?.should be_true
  end

end