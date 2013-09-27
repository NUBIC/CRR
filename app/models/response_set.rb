class ResponseSet < ActiveRecord::Base

  has_many :responses,:dependent=>:destroy
  has_many :answers, :through => :responses
  belongs_to :participant, :touch=>true
  belongs_to :visit_template
  belongs_to :survey

  scope :completed, :conditions => ['response_sets.completed_at IS NOT NULL']


          # Validations
  validates_presence_of :survey_id,:participant_id
  #validates_associated :responses
  #validates_associated_bubbling :responses

  after_initialize :create_question_methods
  #validates_uniqueness_of :access_code

  def create_question_methods
    return nil if survey.nil?
    self.survey.questions.each do |q|
      #creates getter and setter methods for each question
      self.send(:define_singleton_method, "q_#{q.id}".to_sym) do
        if q.response_type.eql?("multiple_choice")
          return responses.where(:question_id=>q.id).collect{|r| r.answer.id}
        elsif q.response_type.eql?("single_choice")
          r = responses.find_by_question_id(q.id)
          return r.nil? ? nil : r.answer.id
        else
          r = responses.find_by_question_id(q.id)
          return r.nil? ? "" : r.text
        end
      end
      self.send(:define_singleton_method, "q_#{q.id}=".to_sym) do |args|
        if q.response_type.eql?("multiple_choice")
          args.reject!{|a| a.empty?}
          new_ids = args.collect{|arg| arg.to_i}
          question_responses = self.responses.where(:question_id=>q.id)
          return question_responses.destroy_all if new_ids.empty?
          answer_ids = question_responses.collect{|r| r.answer.id}
          (answer_ids - new_ids).each do |qa|
            self.responses.find_by_answer_id(qa).destroy
          end
          new_ids.each do |answer_id|
            r = responses.find_or_create_by_question_id_and_answer_id(question_id: q.id, answer_id: answer_id)
          end
        elsif q.response_type.eql?("single_choice")
          return responses.where(:question_id=>q.id).destroy_all if args.blank?
          responses.where(:question_id=>q.id).each{|r| r.destroy unless r.answer.id.eql?(args.to_i)}
          r = responses.find_or_create_by_question_id_and_answer_id(question_id: q.id, answer_id: args.to_i) 
        elsif ["number","long_text","short_text","date"].include?q.response_type
            if args.blank?
              responses.where(:question_id=>q.id).destroy_all
            else
              r = responses.find_or_create_by_question_id_and_answer_id(question_id: q.id)
              r.text=args
              r.save
            end
        end
      end
    end
  end


  def complete?
    !completed_at.nil?
  end


  #TODO
  def mandatory_questions_complete?
    survey.sections.map(&:questions).flatten.compact.each do |q|
      return false if q.is_mandatory? and is_unanswered?(q)
    end
  end

  def is_answered?(question)
    %w(none).include?(question.response_type) or !is_unanswered?(question)
  end

  def is_unanswered?(question)
    self.responses.detect{|r| r.question_id == question.id}.nil?
  end


  def status
    self.completed_at.nil? ? "Started" : "Completed"
  end

  def first_incomplete_section
    survey.sections.detect{|sec| !section_mandatory_questions_complete?(sec)}
  end

  def complete!
    if mandatory_questions_complete? 
      self.completed_at = Time.now
      Scoring.score(self)
      save!
    else
      self.errors.add(:form,"Mandatory questions not complete")
    end
  end
  
end
