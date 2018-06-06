module Helpers
  def set_surveys
    unless @survey.present?
      @survey     = FactoryBot.create(:survey, multiple_section: true)
      @section_1  = @survey.sections.create(title: 'section 1')
      @section_2  = @survey.sections.create(title: 'section 2')
      @questions  = []
      Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
        question  = [@section_1, @section_2].sample.questions.create(text: "question #{i}", response_type: response_type)
        if question.multiple_choice?
          3.times do |i|
            question.answers.create(text: "answer #{i}")
          end
        end
        @questions << question
      end
    end
  end

  def set_results
    unless @participant1.present?
      @participant1 = FactoryBot.create(:participant, stage: 'approved')
      @participant2 = FactoryBot.create(:participant, stage: 'approved')
      @studies      = []
      2.times do
        @studies << FactoryBot.create(:study)
      end
      FactoryBot.create(:study_involvement, participant: @participant1, study: @studies.first)

      set_surveys unless @survey.present?

      @question     = @questions.reject(&:label?).reject(&:file_upload?).sample
      response_set  = @participant1.response_sets.create(survey: @survey)
      create_response(response_set, @question)
      create_search_condition(@question)

      40.times do
        participant = FactoryBot.create(:participant, stage: 'approved')
        response_set = participant.response_sets.create(survey: @survey)
        create_response(response_set, @question)
      end
    end
  end

  def create_response(response_set, question)
    if question.multiple_choice?
      response_set.responses.create(question: question, answer: question.answers.first)
    elsif question.true_date?
      value = Date.today
      response_set.responses.create(question: question, text: value.to_s)
    elsif question.number?
      value = 1
      response_set.responses.create(question: question, text: value)
    else
      value = 'test'
      response_set.responses.create(question: question, text: value)
    end
  end

  def create_search_condition(question)
    if question.multiple_choice?
      search.search_condition_group.search_conditions.create(question: question, operator: 'in', values: question.answers.map(&:id))
    elsif question.true_date?
      value = Date.today
      search.search_condition_group.search_conditions.create(question: question, operator: '=', values: [value.to_s])
    elsif question.number?
      value = 1
      search.search_condition_group.search_conditions.create(question: question, operator: '=', values: [value])
    else
      value = 'test'
      search.search_condition_group.search_conditions.create(question: question, operator: '=', values: [value])
    end
  end
end
