require 'spec_helper'

describe SearchConditionGroup do
  before(:each) do
    @study = FactoryGirl.create(:study)
    @search = @study.searches.create( name: 'test' )
    @participant1 = FactoryGirl.create(:participant, stage: 'approved')
    @participant2 = FactoryGirl.create(:participant, stage: 'approved')
    @participant3 = FactoryGirl.create(:participant, stage: 'approved')
    @search_condition_group = @search.search_condition_group

    @survey       = FactoryGirl.create(:survey, multiple_section: false)
    @section      = @survey.sections.first
    @q_number     = @section.questions.create(text: "test2", response_type: "number",     is_mandatory: true, code: "q_number")
    @q_date       = @section.questions.create(text: "test2", response_type: "date",       is_mandatory: true)
    @q_text       = @section.questions.create(text: "test2", response_type: "long_text",  is_mandatory: true, code: "q_long")
    @q_pick_many  = @section.questions.create(text: "test",  response_type: "pick_many",  is_mandatory: true, code: "q_many")
    @pm_a1 = @q_pick_many.answers.create(text: "one")
    @pm_a2 = @q_pick_many.answers.create(text: "two")
    @pm_a3 = @q_pick_many.answers.create(text: "three")
    @pm_a4 = @q_pick_many.answers.create(text: "four")
  end


  it "should or the result of all search conditions if operator is or" do
    search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2013'])
    search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2013'])
    search_condition1.stub(:result).and_return([@participant1])
    search_condition1.stub(:result).and_return([@participant2])
    @search_condition_group.operator = "|"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant1,@participant2].sort)
  end

  it "should and the result of all search conditions if operator is '&'" do
    search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2013'])
    search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2013'])
    search_condition1.stub(:result).and_return([@participant1,@participant3])
    search_condition1.stub(:result).and_return([@participant2,@participant3])
    @search_condition_group.operator = "&"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant3].sort)
  end
  it "should or the result of all search condition groups if operator is or" do
    search_condition_group1 = @search_condition_group.search_condition_groups.create(:operator=>"|")
    search_condition_group2 = @search_condition_group.search_condition_groups.create(:operator=>"|")
    search_condition_group1.stub(:result).and_return([@participant1])
    search_condition_group2.stub(:result).and_return([@participant2])
    @search_condition_group.operator="|"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant1,@participant2].sort)
  end
  it "should and the result of all search condition groups if operator is or" do
    search_condition_group1 = @search_condition_group.search_condition_groups.create(:operator=>"|")
    search_condition_group2 = @search_condition_group.search_condition_groups.create(:operator=>"|")
    search_condition_group1.stub(:result).and_return([@participant1,@participant3])
    search_condition_group2.stub(:result).and_return([@participant2,@participant3])
    @search_condition_group.operator="|"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant3].sort)
  end
  it "should or the result of all search conditions and  groups if operator is or" do
    search_condition_group = @search_condition_group.search_condition_groups.create(:operator=>"|")
    search_condition = @search_condition_group.search_conditions.create(question: @q_date, values: ['12/12/2003'], operator: ">")
    search_condition_group.stub(:result).and_return([@participant1])
    search_condition.stub(:result).and_return([@participant2])
    @search_condition_group.operator="|"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant1,@participant2].sort)
  end
  it "should and the result of all search conditions and  groups if operator is '&'" do
    search_condition_group = @search_condition_group.search_condition_groups.create(:operator=>"|")
    search_condition = @search_condition_group.search_conditions.create(question: @q_date, values: ['12/12/2003'], operator: ">")
    search_condition_group.stub(:result).and_return([@participant1,@participant3])
    search_condition.stub(:result).and_return([@participant2,@participant3])
    @search_condition_group.operator="&"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant3].sort)
  end
end
