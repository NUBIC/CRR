class SearchCondition < ActiveRecord::Base
  # Globals
  CALCULATED_DATE_UNITS   = { years_ago: 'years ago', months_ago: 'months ago', days_ago: 'days ago' }.freeze

  # Dependencies
  include SearchOperator

  # Attributes
  serialize :values, Array
  attr_accessor :search_values, :calculated_date_units, :calculated_date_numbers, :search_subject, :is_calculated_date

  # Associations
  belongs_to :search_condition_group
  belongs_to :question

  # Validations
  validates_presence_of  :question, :values, :operator
  validates_inclusion_of :operator, in: ->(record) { operators_by_type(operator_type_for_question(record.question)).map{|o| o[:symbol]}}

  # Hooks
  after_initialize  :set_search_attributes, unless: :new_record?
  after_save        :set_search_attributes
  before_validation :set_date_values, :cleanup_values

  def set_date_values
    if question && calculated_date_units && question.true_date? && !calculated_date_units.reject(&:blank?).empty? && !calculated_date_numbers.reject(&:blank?).empty?
      self.values = []
      calculated_date_units.each_with_index do |calculated_date_unit, i|
        calculated_date_number = calculated_date_numbers[i]
        value = calculated_date_number.to_s + ' ' + calculated_date_unit.to_s unless calculated_date_number.blank? || calculated_date_units.blank?
        self.values << value
      end
    end
  end

  def cleanup_values
    return unless question
    operator_type = self.class.operator_type_for_question(question)
    operator_hash = self.class.operators_by_type(operator_type).find{|o| o[:symbol] == operator}
    self.values = [self.values.first] unless (operator_type == LIST_OPERATOR_TYPE) || (operator_hash[:cardinality] && operator_hash[:cardinality] > 1)
  end

  def set_search_attributes
    return unless question
    if question.multiple_choice?
      @search_subject = 'answer_id'
    elsif question.number?
      @search_subject = 'text::decimal'
    elsif question.date? or question.birth_date?
      @search_subject = 'text::date'
    elsif question.long_text? or question.short_text?
      @search_subject = 'lower(text)'
    end

    @search_values            = []
    @calculated_date_units    = []
    @calculated_date_numbers  = []
    if values.any?
      # this logic assumes that all date values are formatted in the same way - either as a date or as a string representation
      @is_calculated_date = question.true_date? && values.map{|value| m = value.match("#{CALCULATED_DATE_UNITS.values.join('|')}")}.any?

      if @is_calculated_date
        current_date = Date.today
        CALCULATED_DATE_UNITS.each do |method, calculated_date_unit|
          values.each do |value|
            if m = value.to_s.match(calculated_date_unit) && current_date.respond_to?(method)
              calculated_date_number  = value.gsub(calculated_date_unit, '').to_i
              @calculated_date_units   << calculated_date_unit
              @calculated_date_numbers << calculated_date_number
              @search_values           << current_date.send(method, calculated_date_number)
            end
          end
        end
      elsif question.long_text? || question.short_text?
        # TODO: find better solution if available for case insensitive search for free text input question
        @search_values = values.map{|value| value.downcase}
      end
      @search_values = values.reject(&:blank?) if @search_values.empty?
    end
  end

  def result
    return [] if disabled?
    operator_type = self.class.operator_type_for_question(question)

    participants = Participant.joins(response_sets: :responses).where(responses: {question_id: question.id}, stage: 'approved')
    if operator_type == LIST_OPERATOR_TYPE
      participants = participants.where("#{search_subject} #{operator} (?)", search_values)
    elsif @is_calculated_date
      case operator
      when 'between'
        participants = participants.where("#{search_subject} #{operator} ? AND ?", *search_values.reverse)
      when '<'
        participants = participants.where("#{search_subject} > ?", search_values.first)
      when '<='
        participants = participants.where("#{search_subject} >= ?", search_values.first)
      when '>'
        participants = participants.where("#{search_subject} < ?", search_values.first)
      when '>='
        participants = participants.where("#{search_subject} <= ?", search_values.first)
      else
        participants = participants.where("#{search_subject} #{operator} ?", search_values.first)
      end
    elsif operator == 'between'
      participants = participants.where("#{search_subject} #{operator} ? AND ?", *search_values)
    else
      participants = participants.where("#{search_subject} #{operator} ?", search_values.first)
    end
    participants
  end

  def get_search
    search_condition_group.get_search
  end

  def display_values
    if question.multiple_choice? and !values.blank?
      display_values = question.answers.where(id: values).map(&:text).join('&nbsp;<small class="muted"><i>or</i></small><br/>').html_safe
    elsif @is_calculated_date
      display_values = values.map.with_index{|value, i| "#{value} (#{search_values[i]})"}.join(',<br/>').html_safe
    else
      display_values = values.join(',<br/>').html_safe
    end
  end

  def self.operator_type_for_question(question)
    return unless question
    if question.multiple_choice?
      LIST_OPERATOR_TYPE
    elsif question.number? || question.true_date?
      NUMERIC_OPERATOR_TYPE
    else
      TEXT_OPERATOR_TYPE
    end
  end

  def pretty_operator
    pretty_operator_by_type(self.class.operator_type_for_question(question)) unless incomplete?
  end

  def disabled?
    incomplete? || values.empty? || question.label?
  end

  def incomplete?
    question.blank? || operator.blank?
  end

  def copy(source_record)
    return unless source_record.is_a?(self.class)
    self.operator     = source_record.operator
    self.question_id  = source_record.question_id
    self.values       = source_record.values
  end
end
