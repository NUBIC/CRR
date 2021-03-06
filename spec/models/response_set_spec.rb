require 'rails_helper'

RSpec.describe ResponseSet, type: :model do
  before(:each) do
    @participant = FactoryBot.create(:participant)
    @survey = FactoryBot.create(:survey, multiple_section: true)
    @section = @survey.sections.create(title: 'test')

    @q_date       = @section.questions.create(text: 'test2', response_type: 'date', is_mandatory: true)
    @q_short_text = @section.questions.create(text: 'test2', response_type: 'short_text', is_mandatory: true)
    @q_long_text  = @section.questions.create(text: 'test2', response_type: 'long_text', is_mandatory: true)
    @q_label      = @section.questions.create(text: 'test2', response_type: 'none', is_mandatory: true)
    @q_pick_many  = @section.questions.create(
      text: 'test', response_type: 'pick_many', is_mandatory: true, code: 'q_many')
    @q_pick_one   = @section.questions.create(
      text: 'test2', response_type: 'pick_one', is_mandatory: true, code: 'q_one')
    @q_number     = @section.questions.create(
      text: 'test2', response_type: 'number', is_mandatory: true, code: 'q_number')

    @pm_a1 = @q_pick_many.answers.create(text: 'one')
    @pm_a2 = @q_pick_many.answers.create(text: 'two')
    @pm_a3 = @q_pick_many.answers.create(text: 'three')
    @pm_a4 = @q_pick_many.answers.create(text: 'four')
    @po_a1 = @q_pick_one.answers.create(text: 'red')
    @po_a2 = @q_pick_one.answers.create(text: 'blue')
    @po_a3 = @q_pick_one.answers.create(text: 'green')
    @po_a4 = @q_pick_one.answers.create(text: 'orange')

    @response_set = @participant.response_sets.create(survey_id: @survey.id)
  end

  describe 'question methods' do
    it 'should create getter setters that correspond to questions in survey' do
      expect(@response_set).to respond_to("q_#{@q_pick_many.id}".to_sym)
      expect(@response_set).to respond_to("q_#{@q_pick_many.id}_string".to_sym)
      expect(@response_set).to respond_to("q_#{@q_pick_many.id}=".to_sym)
    end

    context 'for pick many questions' do
      it 'should accept values' do
        @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => ["#{@pm_a1.id}", "#{@pm_a2.id}"])
        expect(@response_set.reload.responses.size).to eq 2
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id).size).to eq 2
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id, answer_id: @pm_a1.id).size).to eq 1
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id, answer_id: @pm_a2.id).size).to eq 1
      end

      it 'should properly replace value' do
        @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => ["#{@pm_a1.id}", "#{@pm_a2.id}"])
        expect(@response_set.reload.responses.size).to eq 2
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id).size).to eq 2
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id, answer_id: @pm_a1.id).size).to eq 1
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id, answer_id: @pm_a2.id).size).to eq 1

        @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => ["#{@pm_a3.id}", "#{@pm_a4.id}"])
        expect(@response_set.reload.responses.size).to eq 2
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id).size).to eq 2
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id, answer_id: @pm_a3.id).size).to eq 1
        expect(@response_set.reload.responses.where(question_id: @q_pick_many.id, answer_id: @pm_a4.id).size).to eq 1
      end

      it 'should reject answers with the wrong question id' do
        @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => ["#{@po_a1.id}", "#{@po_a2.id}"])
        expect(@response_set.reload.responses.size).to eq 0
      end

      it 'should properly erase value' do
        @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => ["#{@pm_a1.id}", "#{@pm_a2.id}"])
        expect(@response_set.reload.responses.size).to eq 2
        @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => [])
        expect(@response_set.reload.responses.size).to eq 0
      end

      it 'should return answers' do
        @response_set.update_attributes!("q_#{@q_pick_many.id}".to_sym => ["#{@pm_a1.id}", "#{@pm_a2.id}"])
        expect(@response_set.reload.send("q_#{@q_pick_many.id}".to_sym)).to match_array([@pm_a1.id, @pm_a2.id])
      end

      it 'should return string of answers' do
        @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => ["#{@pm_a1.id}", "#{@pm_a2.id}"])
        expect(@response_set.reload.send("q_#{@q_pick_many.id}_string".to_sym)).to eq [@pm_a1.text, @pm_a2.text].join('|')
      end
    end

    context 'for pick one questions' do
      it 'should insert values' do
        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@po_a1.id}")
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.reload.responses.where(question_id: @q_pick_one.id, answer_id: @po_a1.id).size).to eq 1
      end

      it 'should insert different value' do
        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@po_a1.id}")
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.reload.responses.where(question_id: @q_pick_one.id, answer_id: @po_a1.id).size).to eq 1

        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@po_a2.id}")
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.reload.responses.where(question_id: @q_pick_one.id, answer_id: @po_a2.id).size).to eq 1
      end

      it 'should erase values' do
        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@po_a1.id}")
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.reload.responses.where(question_id: @q_pick_one.id, answer_id: @po_a1.id).size).to eq 1

        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => '')
        expect(@response_set.reload.responses.size).to eq 0
      end

      it 'should reject answers with the wrong question id' do
        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@pm_a1.id}")
        expect(@response_set.reload.responses.size).to eq 0
      end

      it 'should return answers' do
        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@po_a1.id}")
        expect(@response_set.reload.send("q_#{@q_pick_one.id}".to_sym)).to eq @po_a1.id
      end

      it 'should return string of answers' do
        @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@po_a1.id}")
        expect(@response_set.reload.send("q_#{@q_pick_one.id}_string".to_sym)).to eq @po_a1.text
      end
    end

    context 'date' do
      it 'should insert value' do
        @response_set.update_attributes("q_#{@q_date.id}".to_sym => '12-12-2013')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_date.id}".to_sym).to_s).to eq '12-12-2013'
      end

      it 'should properly erase value' do
        @response_set.update_attributes("q_#{@q_date.id}".to_sym => '12-12-2013')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_date.id}".to_sym).to_s).to eq '12-12-2013'

        @response_set.update_attributes("q_#{@q_date.id}".to_sym => '')
        expect(@response_set.reload.responses.size).to eq 0
        expect(@response_set.send("q_#{@q_date.id}".to_sym).to_s).to be_blank
      end

      it 'should not insert bad value' do
        @response_set.update_attributes("q_#{@q_date.id}".to_sym => '44/44/2098')
        expect(@response_set.reload.responses.size).to eq 0
        expect(@response_set.send("q_#{@q_date.id}".to_sym).to_s).to be_blank
      end

      it 'should not overwrite previously inserted value when bad value is entered' do
        @response_set.update_attributes("q_#{@q_date.id}".to_sym => '12-12-2013')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_date.id}".to_sym).to_s).to eq '12-12-2013'

        @response_set.update_attributes("q_#{@q_date.id}".to_sym => '54/23/2134')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_date.id}".to_sym).to_s).to eq '12-12-2013'
      end

      it 'should return string of answers' do
        @response_set.update_attributes("q_#{@q_date.id}".to_sym => '12-12-2013')
        expect(@response_set.send("q_#{@q_date.id}_string".to_sym).to_s).to eq '12-12-2013'
      end
    end

    context 'short_text' do
      it 'should insert value for short_text' do
        @response_set.update_attributes("q_#{@q_short_text.id}".to_sym => 'we are in the business of shoting hoops')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_short_text.id}".to_sym).to_s).to eq 'we are in the business of shoting hoops'
      end

      it 'should properly erase value for short_text' do
        @response_set.update_attributes("q_#{@q_short_text.id}".to_sym => 'we are in the business of shoting hoops')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_short_text.id}".to_sym).to_s).to eq 'we are in the business of shoting hoops'

        @response_set.update_attributes("q_#{@q_short_text.id}".to_sym => '')
        expect(@response_set.reload.responses.size).to eq 0
        expect(@response_set.send("q_#{@q_short_text.id}".to_sym).to_s).to be_blank
      end

      it 'should return string of answers' do
        @response_set.update_attributes("q_#{@q_short_text.id}".to_sym => 'we are in the business of shoting hoops')
        expect(@response_set.send("q_#{@q_short_text.id}_string".to_sym).to_s).to eq 'we are in the business of shoting hoops'
      end
    end

    context 'long_text' do
      it 'should insert value for long_text' do
        text = Faker::Lorem.paragraph
        @response_set.update_attributes("q_#{@q_long_text.id}".to_sym => text)
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_long_text.id}".to_sym).to_s).to eq text
      end

      it 'should properly erase value for long_text' do
        text = Faker::Lorem.paragraph
        @response_set.update_attributes("q_#{@q_long_text.id}".to_sym => text)
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_long_text.id}".to_sym).to_s).to eq text

        @response_set.update_attributes("q_#{@q_long_text.id}".to_sym => '')
        expect(@response_set.reload.responses.size).to eq 0
        expect(@response_set.send("q_#{@q_long_text.id}".to_sym).to_s).to be_blank
      end

      it 'should return string of answers' do
        text = Faker::Lorem.paragraph
        @response_set.update_attributes("q_#{@q_long_text.id}".to_sym => text)
        expect(@response_set.send("q_#{@q_long_text.id}_string".to_sym).to_s).to eq text
      end
    end

    context 'number' do
      it 'should insert value for number' do
        @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_number.id}".to_sym).to_s).to eq '3456'
      end

      it 'should not insert bad value for number' do
        @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456fadsfd')
        expect(@response_set.reload.responses.size).to eq 0
        expect(@response_set.send("q_#{@q_number.id}".to_sym).to_s).to be_blank
      end

      it 'should not erase previously inserted number when bad number is provided' do
        @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_number.id}".to_sym).to_s).to eq '3456'

        @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456fadsfdf')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_number.id}".to_sym).to_s).to eq '3456'
      end

      it 'should erase value for number' do
        @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')
        expect(@response_set.reload.responses.size).to eq 1
        expect(@response_set.send("q_#{@q_number.id}".to_sym).to_s).to eq '3456'

        @response_set.update_attributes("q_#{@q_number.id}".to_sym => '')
        expect(@response_set.reload.responses.size).to eq 0
        expect(@response_set.send("q_#{@q_number.id}".to_sym).to_s).to be_blank
      end

      it 'should return string of answers' do
        @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')
        expect(@response_set.send("q_#{@q_number.id}_string".to_sym).to_s).to eq '3456'
      end
    end
  end

  it 'checks if response set is complete' do
    expect(@response_set).not_to be_complete

    @response_set.completed_at = Time.now
    expect(@response_set).to be_complete
  end

  describe 'display text' do
    it 'returns survey title if response set is not complete' do
      expect(@response_set.display_text).to eq @survey.title
    end

    it 'returns indicates if response set is complete' do
      @response_set.completed_at = Time.now
      expect(@response_set.display_text).to match(/completed on #{Date.today}/)
    end
  end

  it 'checks if question is not answered' do
    @section.questions.each do |question|
      expect(@response_set.is_unanswered?(question)).to eq true
    end

    answer_survey_questions
    @section.questions.each do |question|
      if question.response_type == 'none'
        expect(@response_set.is_unanswered?(question)).to eq true
      else
        expect(@response_set.is_unanswered?(question)).to eq false
      end
    end
  end

  it 'checks if question is answered' do
    @section.questions.each do |question|
      if question.response_type == 'none'
        expect(@response_set.is_answered?(question)).to eq true
      else
        expect(@response_set.is_answered?(question)).to eq false
      end
    end

    answer_survey_questions
    @section.questions.each do |question|
      expect(@response_set.is_answered?(question)).to eq true
    end
  end

  it 'returns unanswered mandatory questions' do
    @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')

    expect(@response_set.unanswered_mandatory_questions).to match_array(
      [@q_date, @q_short_text, @q_long_text, @q_pick_many, @q_pick_one]
    )
  end

  it 'detects if mandatory questions are complete' do
    @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')
    expect(@response_set.mandatory_questions_complete?).to be false

    answer_survey_questions
    expect(@response_set.mandatory_questions_complete?).to be true
  end

  it 'returns response set status' do
    expect(@response_set.status).to eq 'Started'

    @response_set.completed_at = Time.now
    expect(@response_set.status).to eq 'Completed'
  end

  it 'checks if response set can be completed' do
    expect(@response_set.can_complete?).to be false

    answer_survey_questions
    expect(@response_set.can_complete?).to be true
  end

  it 'should not complete a survey that doesn\'t have it\'s mandatory sections complete' do
    @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')
    expect(@response_set.reload.responses.size).to eq 1
    expect(@response_set.complete!).to be false
    expect(@response_set.reload.complete?).to be false
  end

  it 'should complete a survey that has all responses complete' do
    answer_survey_questions

    expect(@response_set.reload.responses.size).to eq 6
    expect(@response_set.complete!).to be true
    expect(@response_set.reload.complete?).to be true
  end

  def answer_survey_questions
    @response_set.update_attributes("q_#{@q_number.id}".to_sym => '3456')
    @response_set.update_attributes("q_#{@q_short_text.id}".to_sym => '3456')
    @response_set.update_attributes("q_#{@q_long_text.id}".to_sym => '3456')
    @response_set.update_attributes("q_#{@q_date.id}".to_sym => '12-12-2012')
    @response_set.update_attributes("q_#{@q_pick_one.id}".to_sym => "#{@po_a1.id}")
    @response_set.update_attributes("q_#{@q_pick_many.id}".to_sym => ["#{@pm_a1.id}"])
  end
end
