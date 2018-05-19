require 'rails_helper'

RSpec.describe SearchCondition, type: :model do
  before(:each) do
    @study = FactoryGirl.create(:study)
    @search = @study.searches.create( name: 'test' )
    @search_condition_group = @search.search_condition_group
    @participant1 = FactoryGirl.create(:participant, stage: 'approved')
    @participant2 = FactoryGirl.create(:participant, stage: 'approved')

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

  it { is_expected.to validate_presence_of :question }
  it { is_expected.to validate_presence_of :values }
  it { is_expected.to validate_presence_of :operator }


  describe 'methods' do
    describe 'setting date values' do
      before(:each) do
        @search_condition = @search_condition_group.search_conditions.create(question: @q_date, operator: 'between')
        @search_condition.calculated_date_units    = ['years ago', 'days ago']
        @search_condition.calculated_date_numbers  = [4, 5]
      end

      it 'transcribes calculated date values into values' do
        @search_condition.set_date_values
        expect(@search_condition.values).to match_array(['4 years ago', '5 days ago'])
      end

      it 'does not set values if questions is not set' do
        @search_condition.question = nil
        @search_condition.set_date_values
        expect(@search_condition.values).to be_empty
      end

      it 'does not set values if calculated date units are not set' do
        @search_condition.calculated_date_units = nil
        @search_condition.set_date_values
        expect(@search_condition.values).to be_empty
      end

      it 'does not set values if questions is not a date question' do
        @search_condition.question = @q_number
        @search_condition.set_date_values
        expect(@search_condition.values).to be_empty
      end

      it 'does not set values if calculated_date_units are not set to actual values' do
        @search_condition.calculated_date_units = ['', nil]
        @search_condition.set_date_values
        expect(@search_condition.values).to be_empty
      end

      it 'does not set values if calculated_date_numbers are not set to actual values' do
        @search_condition.calculated_date_numbers = [nil, '']
        @search_condition.set_date_values
        expect(@search_condition.values).to be_empty
      end
    end

    describe 'displaying values' do
      it 'formats multiple choice condition values' do
        search_condition = @search_condition_group.search_conditions.create(
          question: @q_pick_many, operator: 'in', values: [@pm_a1.id.to_s, @pm_a2.id.to_s])
        expect(search_condition.display_values).to match(/#{@pm_a1.text}/)
        expect(search_condition.display_values).to match(/#{@pm_a2.text}/)
      end

      it 'formats calculated date values' do
        @search_condition = @search_condition_group.search_conditions.create(question: @q_date, operator: 'between')
        @search_condition.calculated_date_units    = ['years ago', 'days ago']
        @search_condition.calculated_date_numbers  = [4, 5]
        @search_condition.save!

        expect(@search_condition.display_values).to match(/4 years ago \(#{Date.today.send(:years_ago, 4)}\)/)
        expect(@search_condition.display_values).to match(/5 days ago \(#{Date.today.send(:days_ago, 5)}\)/)
      end

      it 'renders values for numerical conditions' do
        search_condition = @search_condition_group.search_conditions.create(
          question: @q_number, operator: 'between', values: ['9', '11'])
        search_condition.values.each do |value|
          expect(search_condition.display_values).to match(/#{value}/)
        end
      end

      it 'renders values for date conditions' do
        search_condition = @search_condition_group.search_conditions.create(
          question: @q_date,operator: 'between', values: ['12/10/2013', '12/15/2013'])
        search_condition.values.each do |value|
          expect(search_condition.display_values).to match(/#{value}/)
        end
      end

      it 'renders values for text conditions' do
        search_condition = @search_condition_group.search_conditions.create(
          question: @q_text,operator: '!=', values: ['12/12/2013'])
        search_condition.values.each do |value|
          expect(search_condition.display_values).to match(/#{value}/)
        end
      end
    end

    it 'gets parent search' do
      condition = @search_condition_group.search_conditions.new()
      expect(condition.get_search).to eq @search
    end

    describe 'getting results for survey searches' do
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
            expect(search_condition.result).to match_array [@participant2]
          end

          it 'should return participants that fit search "<=" condition' do
            search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '<', values: ['4 years ago'])
            expect(search_condition.result).to match_array [@participant2]
          end

          it 'should return participants that fit search ">" condition' do
            search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '>', values: ['4 years ago'])
            expect(search_condition.result).to match_array [@participant1]
          end

          it 'should return participants that fit search ">=" condition' do
            search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: '>', values: ['4 years ago'])
            expect(search_condition.result).to match_array [@participant1]
          end

          it 'should return participants that fit search "between" condition' do
            search_condition = @search_condition_group.search_conditions.create(question: @q_date,operator: 'between', values: ['1 years ago', '4 years ago'])
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

          @search_condition_group.reload
          @search_condition_group.operator = '&'
          @search_condition_group.save
          search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

          expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]
        end

        it 'allows to reset results for released searches on update' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2015')

          search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2014'])

          @search.request_data
          @search.save!
          expect(@search.search_participants.map(&:participant)).to match_array [@participant2]

          search_condition1.reload
          search_condition1.operator = '<'
          search_condition1.save!

          expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]
        end

        it 'allows to reset results for released searches on destroy' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2015')

          search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])
          search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])

          @search_condition_group.reload
          @search_condition_group.operator = '&'
          @search_condition_group.save

          @search.request_data
          @search.save!
          expect(@search.search_participants.map(&:participant)).to match_array [@participant1]

          search_condition2.reload.destroy
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
          expect(@search.search_participants.map(&:participant)).to match_array [@participant1, @participant2]
          @search.release_data(participant_ids: [@participant1.id])
          @search.save!

          search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])
          @search_condition_group.operator = '&'
          @search_condition_group.save

          expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1, @participant2]
        end

        it 'does not allow to reset results for released searches on update' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2015')

          search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2014'])

          @search.request_data
          @search.save!
          expect(@search.search_participants.map(&:participant)).to match_array [@participant2]
          @search.release_data(participant_ids: [@participant1.id])
          @search.save!

          search_condition1.operator = '<'
          search_condition1.save!

          expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant2]
        end

        it 'does not allow to reset results for released searches on destroy' do
          rs = @participant1.response_sets.create(survey: @survey)
          rs.responses.create(question: @q_date, text: '12/12/2013')
          rs2 = @participant2.response_sets.create(survey: @survey)
          rs2.responses.create(question: @q_date, text: '12/12/2015')

          search_condition1 = @search_condition_group.search_conditions.create( question: @q_date, operator: '>', values: ['12/12/2011'])
          search_condition2 = @search_condition_group.search_conditions.create( question: @q_date, operator: '<', values: ['12/12/2014'])
          @search_condition_group.operator = '&'
          @search_condition_group.save

          @search.request_data
          @search.save!
          expect(@search.search_participants.map(&:participant)).to match_array [@participant1]
          @search.release_data(participant_ids: [@participant1.id])
          @search.save!

          search_condition2.reload.destroy
          expect(@search.reload.search_participants.map(&:participant)).to match_array [@participant1]
        end
      end
    end
  end
end
