module SurveyNodes
  class Node
    include ROXML
  end
  class AnswerNode < Node
    xml_name 'answer'
    xml_accessor :text,:from=>"@text"
    xml_accessor :help_text,:from=>"@help_text"
    xml_accessor :code,:from=>"@code"
    xml_accessor :display_order,:from=>"@display_order"
    def self.from_active_record(answer)
      answer_node = AnswerNode.new
      answer_node.text = answer.text
      answer_node.help_text=answer.help_text
      answer_node.code = answer.code
      answer_node.display_order = answer.display_order
      return answer_node
    end
  end
  class QuestionNode < Node
    xml_name 'question'
    xml_accessor :answers ,:as => [AnswerNode]
    xml_accessor :text,:from=>"@text"
    xml_accessor :help_text,:from=>"@help_text"
    xml_accessor :code,:from=>"@code"
    xml_accessor :display_order,:from=>"@display_order"
    xml_accessor :response_type,:from=>"@response_type"
    xml_accessor :is_mandatory,:from=>"@is_mandatory"
    def self.from_active_record(question)
      question_node = self.new
      question_node.text = question.text
      question_node.help_text=question.help_text
      question_node.code = question.code
      question_node.display_order = question.display_order
      question_node.response_type = question.response_type
      question_node.is_mandatory = question.is_mandatory
      question_node.answers = []
      question.answers.each do |answer|
        question_node.answers << AnswerNode.from_active_record(answer)
      end
      return question_node
    end
  end
  class SectionNode < Node
    xml_name 'section'
    xml_accessor :questions, :as => [QuestionNode]
    xml_accessor :title,:from=>"@title"
    xml_accessor :display_order,:from=>"@display_order"
    def self.from_active_record(section)
      section_node = self.new
      section_node.title = section.title
      section_node.display_order = section.display_order
      section_node.questions=[]
      section.questions.each do |question|
        section_node.questions << QuestionNode.from_active_record(question)
      end
      return section_node
    end
  end
  class SurveyNode < Node
    xml_name 'survey'
    xml_accessor :sections, :as=>[SectionNode]
    xml_accessor :title,:from=>"@title",:from=>"@title"
    xml_accessor :multiple_section,:from=>"@multiple_section"
    xml_accessor :description,:from=>"@description"
    xml_accessor :code,:from=>"@code"

    def self.from_active_record(survey)
      survey_node = self.new
      survey_node.title = survey.title
      survey_node.code = survey.code
      survey_node.description = survey.description
      survey_node.multiple_section = survey.multiple_section
      survey_node.sections = []
      survey.sections.each do |section|
        survey_node.sections << SectionNode.from_active_record(section)
      end
      return survey_node
    end
  end
end
