class Response < ActiveRecord::Base

  belongs_to :response_set
  belongs_to :question
  belongs_to :answer

  validates_presence_of :question_id
  validates_presence_of :answer_id, :if=>:choice?
  validates_presence_of :text, :if=>:data_entry?
  validates_uniqueness_of :answer_id, :scope => :response_set_id,:allow_blank=>true
  validates_uniqueness_of :question_id, :scope => :response_set_id,:allow_blank=>true,:unless=>:multiple_choice?

        #base.send :include, Surveyor::ActsAsResponse # includes "as" instance method


  validate :validate_question_type



  def data_entry?
   ["short_text","long_text","date","number"].include?(self.question.response_type)
  end

  def choice?
    ["single_choice","multiple_choice"].include?(self.question.response_type)
  end

  def multiple_choice?
    question.response_type.eql?("multiple_choice")
  end

  private

  def validate_question_type
    if self.question.response_type.eql?('number')
      begin
        Float(self.text)
      rescue
        errors.add(:question,"#{question.display_order} Is not a valid number")
      end
    elsif self.question.response_type.eql?("date")
      begin
        Date.parse(self.text)
      rescue
        errors.add(:question,"#{question.display_order} Is not a date")
      end
    end
  end
end
