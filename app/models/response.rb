class Response < ActiveRecord::Base
  # Associations
  belongs_to :response_set
  belongs_to :question
  belongs_to :answer

  # Validations
  validates_presence_of :question_id
  validates_presence_of :answer_id, if: :multiple_choice?
  validates_presence_of :text, if: :data_entry?
  validates_uniqueness_of :answer_id, scope: :response_set_id, allow_blank: true
  validates_uniqueness_of :question_id, scope: :response_set_id, allow_blank: true, unless: :pick_many?
  validate :validate_question_type

  def data_entry?
   ['short_text', 'long_text', 'date', 'number'].include?(self.question.response_type)
  end

  def pick_many?
    question.pick_many?
  end

  def multiple_choice?
    question.multiple_choice?
  end

  def to_s
    question.multiple_choice? ? answer.text : self.text
  end

  private
    def validate_question_type
      if self.question.response_type.eql?('number')
        begin
          Float(self.text)
        rescue
          errors.add(:question, "#{question.display_order} is not a valid number")
        end
      elsif self.question.response_type.eql?("date")
        begin
          Date.parse(self.text)
        rescue
          errors.add(:question,"#{question.text} is not a date.")
        end
      elsif self.question.multiple_choice?
        errors.add(:answer, 'doesn\'t match question') unless question.answers.include?(answer)
      end
    end
end
