require 'spec_helper'

describe SearchConditionGroup do
  before(:each) do
    @study = FactoryGirl.create(:study)
    @search = @study.searches.create( name: 'test' )
    @participant1 = FactoryGirl.create(:participant, stage: 'approved')
    @participant2 = FactoryGirl.create(:participant, stage: 'approved')
    @participant3 = FactoryGirl.create(:participant, stage: 'approved')
    @search_condition_group = @search.search_condition_group
  end


  it "should or the result of all search conditions if operator is or" do
    search_condition1 = @search_condition_group.search_conditions.create( condition: @study.event_types.first, operator: '>', values: ['12/12/2013'])
    search_condition2 = @search_condition_group.search_conditions.create( condition: @study.event_types.last, operator: '<', values: ['12/12/2013'])
    search_condition1.stub(:result).and_return([@participant1])
    search_condition1.stub(:result).and_return([@participant2])
    @search_condition_group.operator = "|"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant1,@participant2].sort)
  end

  it "should and the result of all search conditions if operator is '&'" do
    search_condition1 = @search_condition_group.search_conditions.create( condition: @study.event_types.first, operator: '>', values: ['12/12/2013'])
    search_condition2 = @search_condition_group.search_conditions.create( condition: @study.event_types.last, operator: '<', values: ['12/12/2013'])
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
    search_condition = @search_condition_group.search_conditions.create(condition: @study.event_types.first, values: ['12/12/2003'], operator: ">")
    search_condition_group.stub(:result).and_return([@participant1])
    search_condition.stub(:result).and_return([@participant2])
    @search_condition_group.operator="|"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant1,@participant2].sort)
  end
  it "should and the result of all search conditions and  groups if operator is '&'" do
    search_condition_group = @search_condition_group.search_condition_groups.create(:operator=>"|")
    search_condition = @search_condition_group.search_conditions.create(condition: @study.event_types.first, values: ['12/12/2003'], operator: ">")
    search_condition_group.stub(:result).and_return([@participant1,@participant3])
    search_condition.stub(:result).and_return([@participant2,@participant3])
    @search_condition_group.operator="&"
    @search_condition_group.save
    @search_condition_group.result.sort.eql?([@participant3].sort)
  end
end
