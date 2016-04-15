require 'spec_helper'

describe SearchCondition do
  before(:each) do
    @study = FactoryGirl.create(:study)
    @search = @study.searches.create( name: 'test' )
    @search_condition_group = @search.search_condition_group
    @participant1 = FactoryGirl.create(:participant, stage: 'approved')
    @participant2 = FactoryGirl.create(:participant, stage: 'approved')
  end

  it 'should do proper validations' do
    condition = @search_condition_group.search_conditions.new()
    expect(condition).not_to be_valid
    expect(condition.errors.full_messages).to include('Operator can\'t be blank')
    expect(condition.errors.full_messages).to include('Values can\'t be blank')
    expect(condition.errors.full_messages).to include('Question can\'t be blank')
  end

  context 'survey searches' do
    before(:each) do
      @survey       = FactoryGirl.create(:survey, multiple_section: false)
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

    context 'multiple choice' do
      it 'should return participants that fit search "in" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_pick_many,answer: @pm_a1)
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_pick_many, answer: @pm_a2)
        search_condition = @search_condition_group.search_conditions.create(question: @q_pick_many, operator: 'in', values: [@pm_a1.id.to_s, @pm_a2.id.to_s])
        expect(search_condition.result).to match_array([@participant1, @participant2])
      end

      it 'should return participants that fit search "not in" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_pick_many,answer: @pm_a1)
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_pick_many, answer: @pm_a2)

        search_condition = @search_condition_group.search_conditions.create(question: @q_pick_many, operator: 'not in', values: [@pm_a1.id.to_s, @pm_a2.id.to_s])
        expect(search_condition.result).to be_empty

        search_condition = @search_condition_group.search_conditions.create(question: @q_pick_many, operator: 'not in', values: [@pm_a1.id.to_s])
        expect(search_condition.result).to match_array [@participant2]
      end
    end

    context 'numerical questions' do
      it 'should return participants that fit search "=" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_number, text: '10')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_number, text: '20')
        search_condition = @search_condition_group.search_conditions.create(question: @q_number, operator: '=', values: ['10'])
        expect(search_condition.result).to match_array [@participant1]
      end

      it 'should return participants that fit search "!=" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_number, text: '10')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_number, text: '20')
        search_condition = @search_condition_group.search_conditions.create(question: @q_number,operator: '!=', values: ['10'])
        expect(search_condition.result).to match_array [@participant2]
      end

      it 'should return participants that fit search "<" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_number, text: '10')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_number, text: '20')
        search_condition = @search_condition_group.search_conditions.create(question: @q_number, operator: '<', values: ['20'])
        expect(search_condition.result).to match_array [@participant1]
      end

      it 'should return participants that fit search ">" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_number, text: '10')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_number, text: '20')
        search_condition = @search_condition_group.search_conditions.create(question: @q_number, operator: '>', values: ['10'])
        expect(search_condition.result).to match_array [@participant2]
      end

      it 'should return participants that fit search "between" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_number, text: '10')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_number, text: '20')
        search_condition = @search_condition_group.search_conditions.create(question: @q_number, operator: 'between', values: ['9', '11'])
        expect(search_condition.result).to match_array [@participant1]
      end
    end

    context 'date questions' do
      describe 'provided with date values' do
        it 'should return participants that fit search "=" condition' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2014')
          search_condition = @search_condition_group.search_conditions.create(question: @q_date, operator: '=', values: ['12/12/2013'])
          expect(search_condition.result).to eq [@participant1]
        end

        it 'should return participants that fit search "!=" condition' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2014')
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '!=', values: ['12/12/2013'])
          expect(search_condition.result).to match_array [@participant2]
        end

        it 'should return participants that fit search "<" condition' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2014')
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '<', values: ['12/12/2014'])
          expect(search_condition.result).to match_array [@participant1]
        end

        it 'should return participants that fit search ">" condition' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2014')
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '>', values: ['12/12/2013'])
          expect(search_condition.result).to match_array [@participant2]
        end

        it 'should return participants that fit search "between" condition' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2014')
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: 'between', values: ['12/10/2013', '12/15/2013'])
          expect(search_condition.result).to match_array [@participant1]
        end
      end

      describe 'provided with calculated date values' do
        before(:each) do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: (Date.today - 5.years).to_s)
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: (Date.today - 3.years).to_s)
        end

        it 'should return participants that fit search "=" condition' do
          search_condition = @search_condition_group.search_conditions.create(question: @q_date, operator: '=', values: ['5 years ago'])
          expect(search_condition.result).to match_array [@participant1]
        end

        it 'should return participants that fit search "!=" condition' do
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '!=', values: ['5 years ago'])
          expect(search_condition.result).to match_array [@participant2]
        end

        it 'should return participants that fit search "<" condition' do
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '<', values: ['4 years ago'])
          expect(search_condition.result).to match_array [@participant1]
        end

        it 'should return participants that fit search ">" condition' do
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '>', values: ['4 years ago'])
          expect(search_condition.result).to match_array [@participant2]
        end

        it 'should return participants that fit search "between" condition' do
          search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: 'between', values: ['4 years ago', '1 years ago'])
          expect(search_condition.result).to match_array [@participant2]
        end
      end
    end

    context 'text questions' do
      it 'should return participants that fit search "=" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_text, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_text, text: '12/12/2014')
        search_condition = @search_condition_group.search_conditions.create(question: @q_text,operator: '=', values: ['12/12/2013'])
        expect(search_condition.result).to match_array [@participant1]
      end

      it 'should return participants that fit search "!=" condition' do
        rs = @participant1.response_sets.create(survey: @survey)
        rs.responses.create(question: @q_text, text: '12/12/2013')
        rs2 = @participant2.response_sets.create(survey: @survey)
        rs2.responses.create(question: @q_text, text: '12/12/2014')
        search_condition = @search_condition_group.search_conditions.create(question: @q_text,operator: '!=', values: ['12/12/2013'])
        expect(search_condition.result).to match_array [@participant2]
      end
    end
  end
end
