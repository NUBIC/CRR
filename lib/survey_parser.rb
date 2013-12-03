require 'surveys/survey_nodes'
class SurveyParser
  def self.from_xml(data)
    survey_node = SurveyNodes::SurveyNode.from_xml(data)
    survey = Survey.new(:title=>survey_node.title,:code=>survey_node.code,:multiple_section=>survey_node.multiple_section)
    survey.save
    raise survey.errors.full_messages.to_sentence unless survey.save
    survey_node.sections.each do |section_node|
      section = survey.multiple_section? ? survey.sections.new(title: section_node.title,display_order: section_node.display_order) : survey.sections.first
      survey.destroy unless section.save
      raise section.errors.full_messages.to_sentence unless section.save
      section.reload
      section_node.questions.each do |question_node|
        question = section.questions.new(:text=>question_node.text,:help_text=>question_node.text,:code=>question_node.code,:response_type=>question_node.response_type,:is_mandatory=>question_node.is_mandatory,:display_order=>question_node.display_order)
        survey.destroy unless question.save
        raise question.full_messages.to_sentence unless question.save
        question.reload
        question_node.answers.each do |answer_node|
          answer = question.answers.new(:text=>answer_node.text,:help_text=>answer_node.help_text,:code=>answer_node.help_text,:display_order=>answer_node.display_order)
          survey.destroy unless answer.save
          raise answer.full_messages.to_sentence unless answer.save
        end
      end
    end
  end
  def self.to_xml(survey)
    survey_node = SurveyNodes::SurveyNode.from_active_record(survey)
    survey_node.to_xml
  end
end
