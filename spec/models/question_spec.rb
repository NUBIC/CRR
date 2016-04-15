require 'spec_helper'

describe Question do
  before(:each) do
    @survey   = FactoryGirl.create(:survey, multiple_section: true)
    @section  = @survey.sections.create(title: 'test')
  end

  it 'should now allow answers for response_types other than multiple choice' do
    ['date', 'number', 'long_text', 'short_text', 'label'].each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      question.answers.build(text: 'test', question: @question)
      expect(question).not_to be_valid
      expect(question.errors[:type].size).to be >= 1
    end
  end

  it 'should not allow duplicate codes accross sections' do
    question  = @section.questions.create(text: 'test1', response_type: 'pick_many', code: 'q_2')
    section2  = @survey.sections.create(title: 'test2')
    question2 = section2.questions.create(text: 'test2', response_type: 'pick_many', code: 'q_2')
    expect(question2).not_to be_valid
    expect(question2.errors[:code].size).to be >= 1
  end
end
