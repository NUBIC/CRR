class SearchCondition < ApplicationRecord
  # Globals
  CALCULATED_DATE_UNITS   = { years_ago: 'years ago', months_ago: 'months ago', days_ago: 'days ago' }.freeze

  # Dependencies
  include SearchOperator

  # Attributes
  serialize :values, Array
  attr_accessor :search_values, :calculated_date_units, :calculated_date_numbers, :search_subject

  # Associations
  belongs_to :search_condition_group
  belongs_to :question

  # Validations
  validates_presence_of  :question, :values, :operator
  validates_inclusion_of :operator, in: ->(record) { operators_by_type(operator_type_for_question(record.question)).map{|o| o[:symbol]}}
  validate :check_values_order

  # Hooks
  after_initialize  :set_search_attributes, unless: :new_record?
  after_save        :set_search_attributes, :reset_search_results
  before_validation :set_values_from_calculated_date_attributes, :cleanup_values
  after_destroy     :reset_search_results

  def set_values_from_calculated_date_attributes
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
    self.values = [self.values.first] unless list_operator?(operator_type) || (operator_hash[:cardinality] && operator_hash[:cardinality] > 1)
  end

  def check_values_order
    if self.operator == 'between' && values.any?
      correct_order = true
      if question.true_date?
        if is_calculated_date
          set_search_attributes
          correct_order = false if calculated_date_numbers.last.to_i < calculated_date_numbers.first.to_i
        else
          correct_order = false if Date.parse(values.last) < Date.parse(values.first)
        end
      else
        correct_order = false if values.last.to_i < values.first.to_i
      end
      self.errors.add(:base, 'Smaller value should be entered first') unless correct_order
    end
  end

  def is_calculated_date
    question.true_date? && values.map{|value| m = value.match("#{CALCULATED_DATE_UNITS.values.join('|')}")}.any?
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
      if is_calculated_date
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
    if list_operator?(operator_type)
      participants = participants.where("#{search_subject} #{operator} (?)", search_values)
    elsif is_calculated_date
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
    elsif is_calculated_date
      display_values = values.map.with_index{|value, i| "#{value} (#{search_values[i]})"}.join(',<br/>').html_safe
    else
      display_values = values.join(',<br/>').html_safe
    end
  end

  def self.operator_type_for_question(question)
    return unless question
    if question.multiple_choice?
      list_operator_type
    elsif question.number? || question.true_date?
      numeric_operator_type
    else
      text_operator_type
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

  def reset_search_results
    parent_search = self.get_search
    if parent_search.data_requested?
      parent_search.search_participants.destroy_all
      parent_search.set_search_participants
    end
  end
end
