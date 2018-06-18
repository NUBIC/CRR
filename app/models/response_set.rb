require 'csv'

class ResponseSet < ApplicationRecord
  # Associations
  has_many :responses, dependent: :destroy
  has_many :answers, through: :responses
  belongs_to :participant, touch: true
  belongs_to :survey

  # Validations
  validates_presence_of :survey_id, :participant_id

  # Hooks
  after_initialize :create_question_methods
  after_create :send_alert

  # Named scopes
  scope :completed, -> { where('response_sets.completed_at IS NOT NULL') }

  def create_question_methods
    return nil if survey.nil?
    self.survey.questions.each do |q|
      #creates getter and setter methods for each question

      self.send(:define_singleton_method, "q_#{q.id}".to_sym) do
        if q.pick_many?
          return responses.collect{|res| res.answer_id if res.question_id.eql?(q.id)}.compact
        elsif q.pick_one?
          r = responses.detect{|response| response.question_id.eql?(q.id)}
          return r.nil? ? nil : r.answer.id
        else
          r = responses.detect{|response| response.question_id.eql?(q.id)}
          return r.nil? ? '' : r.to_s
        end
      end

      self.send(:define_singleton_method, "q_#{q.id}_string".to_sym) do
        if q.pick_many?
          return responses.collect{|res| res.answer.text if res.question_id.eql?(q.id)}.compact.join('|')
        elsif q.pick_one?
          r = responses.detect{|response| response.question_id.eql?(q.id)}
          return r.nil? ? nil : r.answer.text
        else
          r = responses.detect{|response| response.question_id.eql?(q.id)}
          return r.nil? ? '' : r.to_s
        end
      end

      self.send(:define_singleton_method, "q_#{q.id}=".to_sym) do |args|
        if q.pick_many?
          args.reject!{|a| a.empty?}
          new_ids = args.collect{|arg| arg.to_i}
          question_responses = self.responses.select{|response| response.question_id.eql?(q.id)}
          return question_responses.each{|qr| qr.destroy} if new_ids.empty?
          answer_ids = question_responses.collect{|r| r.answer.id}
          (answer_ids - new_ids).each do |qa|
            self.responses.detect{|response| response.answer_id.eql?(qa)}.destroy
          end
          (new_ids-answer_ids).each do |answer_id|
            r = responses.create(question_id: q.id, answer_id: answer_id)
          end
        elsif q.pick_one?
          return responses.select{|response| response.question_id.eql?(q.id)}.each{|res| res.destroy} if args.blank?
          responses.select{|response| response.question_id.eql?(q.id)}.each{|r| r.destroy unless r.answer.id.eql?(args.to_i)}
          r = responses.detect{|res| res.question_id.eql?(q.id) && res.answer_id.eql?(args.to_i)} || responses.create(question_id: q.id, answer_id: args.to_i)
        elsif q.file_upload?
          r = responses.detect{|res| res.question_id.eql?(q.id)} || responses.create(question_id: q.id)
          r.file_upload = args
          r.save
        elsif q.number? || q.long_text? || q.short_text? || q.date? || q.birth_date?
          if args.blank?
            responses.select{|response| response.question_id.eql?(q.id)}.each{|res| res.destroy}
          else
            r = responses.detect{|res| res.question_id.eql?(q.id)} || responses.create(question_id: q.id)
            r.text = args
            r.save
          end
        end
      end

      if q.file_upload?
        self.send(:define_singleton_method, "q_#{q.id}_remove_file_upload".to_sym) do
          r = responses.detect{|res| res.question_id.eql?(q.id)} || responses.create(question_id: q.id)
          r.remove_file_upload
        end

        self.send(:define_singleton_method, "q_#{q.id}_remove_file_upload=".to_sym) do |args|
          r = responses.detect{|res| res.question_id.eql?(q.id)} || responses.create(question_id: q.id)
          r.remove_file_upload = args
          r.save
        end
      end
    end
  end

  def complete?
    !completed_at.nil?
  end

  def display_text
    complete? ? "#{survey.title} completed on #{completed_at.to_date}" : survey.title
  end

  def is_unanswered?(question)
    self.responses.select{|r| r.question_id.eql?(question.id)}.empty?
  end

  def is_answered?(question)
    %w(none).include?(question.response_type) || !is_unanswered?(question)
  end

  def unanswered_mandatory_questions
    self.survey.questions.select{|q| !q.response_type.eql?('none') && q.is_mandatory? && is_unanswered?(q)}
  end


  def mandatory_questions_complete?
    self.unanswered_mandatory_questions.empty?
  end

  def status
    self.completed_at.nil? ? 'Started' : 'Completed'
  end

  def can_complete?
    mandatory_questions_complete?
  end

  def complete!
    if mandatory_questions_complete?
      self.completed_at = Time.now
      self.participant.process_approvement! if self.participant.survey?
      return save!
    else
      error_string = unanswered_mandatory_questions.collect{|q| "#{q.section.title if survey.sections.size > 1}#{' - ' if survey.sections.size > 1} #{q.display_order}"  }
      self.errors.add(:questions,"#{error_string.join(',')} not answered")
      return false
    end
  end

  def load_from_file(file)
    sections        = self.survey.sections.to_a
    pin_header      = 'PIN'
    section_header  = 'Inst'

    if file.blank?
      self.errors.add(:base, 'File in not provided')
    else
      begin
        CSV.new(file.read, { headers: true }).each do |row|
          unless row[pin_header].blank?
            if row[pin_header] != participant.id.to_s
              self.errors.add(:base, 'Participant PIN does not match')
            else
              section = sections.select{|s| s.title.strip == row[section_header].strip}.first
              if section.blank?
                self.errors.add(:base, "section '#{row[section_header]}' could not be found")
              else
                questions = section.questions
                row.headers.reject{|h| [pin_header, section_header].include?(h)}.each do |header|
                  question = questions.select{|q| q.text.strip == header.strip}.first
                  if question.blank?
                    self.errors.add(:base, "section #{section.title}: question '#{header}' could not be found")
                  else
                    all_responses = self.responses
                    response = all_responses.select{|r| r.question_id == question.id}.first
                    response ||= responses.build(question: question)
                    response.text = row[header]
                  end
                end
              end
            end
          end
        end
      rescue Exception => e
        self.errors.add(:base, 'Error parsing the file' + e.inspect)
      end
    end
  end

  private
    def send_alert
      if self.public? && !self.email.blank?
        SurveyMailer.new_survey_alert(self).deliver_now!
      end
    end
end
