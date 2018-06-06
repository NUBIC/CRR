require 'rails_helper'

RSpec.describe SearchConditionGroup, type: :model do
  before(:each) do
    @study = FactoryBot.create(:study)
    @search = @study.searches.create( name: 'test' )
    @participant1 = FactoryBot.create(:participant, stage: 'approved')
    @participant2 = FactoryBot.create(:participant, stage: 'approved')
    @participant3 = FactoryBot.create(:participant, stage: 'approved')
    @search_condition_group = @search.search_condition_group

    @survey       = FactoryBot.create(:survey, multiple_section: false)
    @section      = @survey.sections.first
    @q_number     = @section.questions.create(text: 'test2', response_type: 'number',     is_mandatory: true, code: 'q_number')
    @q_date       = @section.questions.create(text: 'test2', response_type: 'date',       is_mandatory: true)
    @q_text       = @section.questions.create(text: 'test2', response_type: 'long_text',  is_mandatory: true, code: 'q_long')
    @q_pick_many  = @section.questions.create(text: 'test',  response_type: 'pick_many',  is_mandatory: true, code: 'q_many')
    @pm_a1 = @q_pick_many.answers.create(text: 'one')
    @pm_a2 = @q_pick_many.answers.create(text: 'two')
    @pm_a3 = @q_pick_many.answers.create(text: 'three')
    @pm_a4 = @q_pick_many.answers.create(text: 'four')
  end

  it 'should or the result of all search conditions if operator is or' do
    search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2013'])
    search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2013'])
    allow(search_condition1).to receive(:result).and_return([@participant1])
    allow(search_condition2).to receive(:result).and_return([@participant2])
    @search_condition_group.operator = '|'
    @search_condition_group.save
    expect(@search_condition_group.result).to match_array([@participant1, @participant2])
  end

  it 'should and the result of all search conditions if operator is &' do
    search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2013'])
    search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2013'])
    allow(search_condition1).to receive(:result).and_return([@participant1, @participant3])
    allow(search_condition2).to receive(:result).and_return([@participant2, @participant3])
    @search_condition_group.operator = '&'
    @search_condition_group.save
    expect(@search_condition_group.result).to match_array([@participant3])
  end

  it 'should or the result of all search condition groups if operator is or' do
    search_condition_group1 = @search_condition_group.search_condition_groups.create(operator: '|')
    search_condition_group2 = @search_condition_group.search_condition_groups.create(operator: '|')
    allow(search_condition_group1).to receive(:result).and_return([@participant1])
    allow(search_condition_group2).to receive(:result).and_return([@participant2])
    @search_condition_group.operator = '|'
    @search_condition_group.save
    expect(@search_condition_group.result).to match_array([@participant1, @participant2])
  end

  it 'should and the result of all search condition groups if operator is or' do
    search_condition_group1 = @search_condition_group.search_condition_groups.create(operator: '|')
    search_condition_group2 = @search_condition_group.search_condition_groups.create(operator: '|')
    allow(search_condition_group1).to receive(:result).and_return([@participant1, @participant3])
    allow(search_condition_group2).to receive(:result).and_return([@participant2, @participant3])
    @search_condition_group.operator = '&'
    @search_condition_group.save
    expect(@search_condition_group.result).to match_array([@participant3])
  end

  it 'should or the result of all search conditions and  groups if operator is or' do
    search_condition_group = @search_condition_group.search_condition_groups.create(operator: '|')
    search_condition = @search_condition_group.search_conditions.create(question: @q_date, values: ['12/12/2003'], operator: '>')
    allow(search_condition_group).to receive(:result).and_return([@participant1])
    allow(search_condition).to receive(:result).and_return([@participant2])
    @search_condition_group.operator = '|'
    @search_condition_group.save
    expect(@search_condition_group.result).to match_array([@participant1, @participant2])
  end

  it 'should and the result of all search conditions and  groups if operator is &' do
    search_condition_group = @search_condition_group.search_condition_groups.create(operator: '|')
    search_condition = @search_condition_group.search_conditions.create(question: @q_date, values: ['12/12/2003'], operator: '>')
    allow(search_condition_group).to receive(:result).and_return([@participant1, @participant3])
    allow(search_condition).to receive(:result).and_return([@participant2, @participant3])
    @search_condition_group.operator = '&'
    @search_condition_group.save
    expect(@search_condition_group.result).to match_array([@participant3])
  end

  it 'inverts current operator' do
    @search_condition_group.operator = '|'
    expect(@search_condition_group.invert_operator).to eq '&'

    @search_condition_group.operator = '&'
    expect(@search_condition_group.invert_operator).to eq '|'
  end

  it 'detects "OR" grouping' do
    @search_condition_group.operator = '|'
    expect(@search_condition_group).to be_is_or

    @search_condition_group.operator = '&'
    expect(@search_condition_group).not_to be_is_or
  end

  it 'detects "AND" grouping' do
    @search_condition_group.operator = '&'
    expect(@search_condition_group).to be_is_and

    @search_condition_group.operator = '|'
    expect(@search_condition_group).not_to be_is_and
  end

  describe 'detecting search conditions' do
    it 'returns false if there are no search conditions in the group' do
      expect(@search_condition_group).not_to have_conditions
    end

    it 'returns true if group has search conditions' do
      search_condition = @search_condition_group.search_conditions.create(question: @q_date, values: ['12/12/2003'], operator: '>')
      expect(@search_condition_group).to have_conditions
    end

    it 'returns false if search condition group has group without conditions' do
      search_condition_group = @search_condition_group.search_condition_groups.create
      expect(@search_condition_group).not_to have_conditions
    end

    it 'returns true if search condition group has group with conditions' do
      search_condition_group = @search_condition_group.search_condition_groups.create
      search_condition = search_condition_group.search_conditions.create(question: @q_date, values: ['12/12/2003'], operator: '>')
      expect(@search_condition_group).to have_conditions
    end
  end

  it 'returns pretty operator' do
    @search_condition_group.operator = '&'
    expect(@search_condition_group.pretty_operator).to eq 'AND'

    @search_condition_group.operator = '|'
    expect(@search_condition_group.pretty_operator).to eq 'OR'
  end

  describe 'getting parent search' do
    it 'gets parent search for root search condition group' do
      expect(@search_condition_group.get_search).to eq @search
    end

    it 'gets parent search from parent search condition group if current search condition group is nested' do
      search_condition_group = @search_condition_group.search_condition_groups.create
      expect(search_condition_group.search_condition_group).to receive(:get_search).and_return(@search)
      search_condition_group.get_search
    end
  end

  describe 'copying' do
    before(:each) do
      @source_search_condition_group = @search_condition_group.search_condition_groups.create(operator: '&')
      (1..rand(10)).map{ @source_search_condition_group.search_conditions.create(question: @q_date, values: ['12/12/2003'], operator: '>') }
      (1..rand(10)).map{ @source_search_condition_group.search_condition_groups.create }
      @new_search_condition_group = @search_condition_group.search_condition_groups.create(operator: '|')
    end

    it 'fails to copy from another class' do
      expect{@new_search_condition_group.copy(@search)}.to raise_error(TypeError).with_message('source has to be an object of class SearchConditionGroup')
    end

    it 'copies operator from the source record' do
      @new_search_condition_group.copy(@source_search_condition_group)
      expect(@new_search_condition_group.operator).to eq @source_search_condition_group.operator
    end

    it 'copies search conditions from the source record' do
      @new_search_condition_group.copy(@source_search_condition_group)
      expect(@new_search_condition_group.search_conditions.size).to eq @source_search_condition_group.search_conditions.size
    end

    it 'copies search condition groups from the source record' do
      @new_search_condition_group.copy(@source_search_condition_group)
      expect(@new_search_condition_group.search_condition_groups.size).to eq @source_search_condition_group.search_condition_groups.size
    end
  end

  describe 'reseting search results' do
    context 'submitted searches' do
      it 'allows to reset results for released searches on create' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_date, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_date, text: '12/12/2015')

        search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])

        @search.request_data
        @search.save!
        expect(@search.search_participants.map(&:participant)).to match_array [@participant1, @participant2]

        @search_condition_group.operator = '&'
        @search_condition_group.save

        search_condition_group = @search_condition_group.search_condition_groups.create
        search_condition2      = search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]
      end

      it 'allows to reset results for released searches on update' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_date, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_date, text: '12/12/2015')

        search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])
        search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

        @search.request_data
        @search.save!
        expect(@search.search_participants.map(&:participant)).to match_array [@participant1, @participant2]

        @search_condition_group.reload
        @search_condition_group.operator = '&'
        @search_condition_group.save

        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]
      end

      it 'allows to reset results for released searches on destroy' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_date, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_date, text: '12/12/2015')

        @search_condition_group.operator = '&'
        @search_condition_group.save

        search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])
        search_condition_group = @search_condition_group.search_condition_groups.create
        search_condition2      = search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

        @search.request_data
        @search.save!
        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]

        @search_condition_group.reload
        search_condition_group.reload
        search_condition_group.destroy
        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1, @participant2]
      end
    end

    context 'released searches' do
      it 'does not allow to reset results for released searches on create' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_date, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_date, text: '12/12/2015')

        search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])

        @search.request_data
        @search.save!
        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1, @participant2]

        @search.release_data(participant_ids: [@participant1.id])
        @search.save!

        @search_condition_group.operator = '&'
        @search_condition_group.save

        search_condition_group = @search_condition_group.search_condition_groups.create
        search_condition2      = search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1, @participant2]
      end

      it 'does not allow to reset results for released searches on update' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_date, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_date, text: '12/12/2015')

        search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])
        search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

        @search.request_data
        @search.save!
        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1, @participant2]

        @search.release_data(participant_ids: [@participant1.id])
        @search.save!

        @search_condition_group.reload
        @search_condition_group.operator = '&'
        @search_condition_group.save

        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1, @participant2]
      end

      it 'does not allow to reset results for released searches on destroy' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_date, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_date, text: '12/12/2015')

        @search_condition_group.operator = '&'
        @search_condition_group.save

        search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])
        search_condition_group = @search_condition_group.search_condition_groups.create
        search_condition2      = search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

        @search.request_data
        @search.save!
        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]

        @search.release_data(participant_ids: [@participant1.id])
        @search.save!

        @search_condition_group.reload
        search_condition_group.reload.destroy
        expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]
      end
    end
  end
end
