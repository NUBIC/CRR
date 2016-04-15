require 'spec_helper'

describe Answer do
  before(:each) do
    @survey   = FactoryGirl.create(:survey, multiple_section: true)
    @section  = @survey.sections.create(title: 'title')
    @question = @section.questions.create(text: 'hello', response_type: 'pick_many')
  end

  it 'ensures that all the answers on a question have a unique display_order attribute' do
    first_answer = @question.answers.create(question_id: @question.id, display_order: 0, text: 'Answer #1')

    second_answer = Answer.new(question_id: @question.id, display_order: 0, text: 'Answer #2', code: 'a_2')
    expect(second_answer).not_to be_valid
    expect{second_answer.save!}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Display order has already been taken')

    second_answer.display_order = 1
    expect(second_answer).to be_valid
    expect{second_answer.save!}.not_to raise_error

    second_answer.display_order = 0
    expect(second_answer).not_to be_valid
    expect{second_answer.save!}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Display order has already been taken')
  end

  it 'should not allow answer for wrong display type' do
    ['date', 'number', 'long_text', 'short_text', 'label'].each do |response_type|
      @question.update_attribute(:response_type, response_type)
      answer = @question.answers.new(question_id: @question.id, text: 'test')
      expect(answer).not_to be_valid
      expect(answer.errors[:question].size).to be >= 1
    end
  end
end
