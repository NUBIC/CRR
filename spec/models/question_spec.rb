require 'rails_helper'

RSpec.describe Question, type: :model do
  before(:each) do
    @survey   = FactoryBot.create(:survey, multiple_section: true)
    @section  = @survey.sections.create(title: 'test')
  end

  context 'associations' do
    before { subject = @section.questions.build() }
    it { is_expected.to belong_to(:section) }
    it { is_expected.to have_many(:answers) }
  end

  context 'validations' do
    before { subject = @section.questions.build() }
    it { is_expected.to validate_presence_of(:text)}
    it { is_expected.to validate_presence_of(:display_order)}
    it { is_expected.to validate_presence_of(:response_type)}
    it { is_expected.to validate_presence_of(:code)}
    it { is_expected.to validate_presence_of(:section)}

    it { is_expected.to validate_uniqueness_of(:display_order).scoped_to(:section_id) }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:section_id) }
  end

  it 'allows to search by text' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
    end

    expect(Question.search('test')).to match_array(@section.questions.where.not(response_type: 'none'))
  end

  it 'returns soft errors' do
    question  = @section.questions.create(text: 'test1', response_type: 'pick_many', code: 'q_2')
    expect(question.soft_errors).to eq 'multiple choice questions must have at least 2 answers'

    pm_a1 = question.answers.create(text: 'one')
    pm_a2 = question.answers.create(text: 'two')
    expect(question.soft_errors).to be_blank
  end

  it 'checks if question is a multiple choice' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if ['pick_one', 'pick_many'].include?(response_type)
        expect(question).to be_multiple_choice
      else
        expect(question).not_to be_multiple_choice
      end
    end
  end

  it 'checks if question is a pick many' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'pick_many'
        expect(question).to be_pick_many
      else
        expect(question).not_to be_pick_many
      end
    end
  end

  it 'checks if question is a pick one' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'pick_one'
        expect(question).to be_pick_one
      else
        expect(question).not_to be_pick_one
      end
    end
  end

  it 'checks if question is a date' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'date'
        expect(question).to be_date
      else
        expect(question).not_to be_date
      end
    end
  end

  it 'checks if question is a birth date' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'birth_date'
        expect(question).to be_birth_date
      else
        expect(question).not_to be_birth_date
      end
    end
  end

  it 'checks if question is a true date' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if ['birth_date', 'date'].include?(response_type)
        expect(question).to be_true_date
      else
        expect(question).not_to be_true_date
      end
    end
  end

  it 'checks if question is a long text' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'long_text'
        expect(question).to be_long_text
      else
        expect(question).not_to be_long_text
      end
    end
  end

  it 'checks if question is a short text' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'short_text'
        expect(question).to be_short_text
      else
        expect(question).not_to be_short_text
      end
    end
  end

  it 'checks if question is a number' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'number'
        expect(question).to be_number
      else
        expect(question).not_to be_number
      end
    end
  end

  it 'checks if question is a label' do
    Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      if response_type == 'none'
        expect(question).to be_label
      else
        expect(question).not_to be_label
      end
    end
  end

  it 'provides search display' do
    question  = @section.questions.create(text: 'test1', response_type: 'pick_many', code: 'q_2')
    expect(question.search_display).to match(/#{@section.survey.title}/)
    expect(question.search_display).to match(/#{@section.survey.title}/)
    expect(question.search_display).to match(/#{question.text}/)
  end

  it 'should now allow answers for response_types other than multiple choice' do
    ['date', 'number', 'long_text', 'short_text', 'label'].each_with_index do |response_type, i|
      question  = @section.questions.create(text: "test#{i}", section_id: @section.id, response_type: response_type)
      question.answers.build(text: 'test', question: question)
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

  it 'removes trailing spaces from question text' do
    question  = @section.questions.create(text: ' test1 ', response_type: 'pick_many', code: 'q_2')
    expect(question.text).to eq 'test1'

    question.text = '  test1  '
    question.save
    expect(question.text).to eq 'test1'
  end
end
