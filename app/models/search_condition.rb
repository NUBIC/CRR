# == Schema Information
#
# Table name: search_conditions
#
#  id                        :integer          not null, primary key
#  search_condition_group_id :integer
#  operator                  :string(255)
#  question_id               :integer
#  value                     :string(255)
#

class SearchCondition < ActiveRecord::Base
  include SearchOperator

  belongs_to :search_condition_group
  belongs_to :question

  VALID_ANSWER_OPERATORS  = ['=','!='].freeze
  COMPUTED_DATE_UNITS     = { years_ago: 'years ago', months_ago: 'months ago', days_ago: 'days ago' }.freeze

  # validates_inclusion_of :operator, in: comparison_operators.map{|o| o[:symbol]}
  validates_presence_of  :question

  attr_accessor :search_value, :calculated_date_units, :calculated_date_number, :search_subject, :is_calculated_date

  after_initialize  :set_search_attributes, unless: Proc.new { |record| record.new_record? }
  after_save        :set_search_attributes
  before_save       :set_date_value

  def set_date_value
    self.value = calculated_date_number.to_s + ' ' + calculated_date_units.to_s unless calculated_date_number.blank? || calculated_date_units.blank?
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

    @search_value       = value

    if value
      @is_calculated_date = question.true_date? && m = value.match("#{COMPUTED_DATE_UNITS.values.join('|')}")

      if @is_calculated_date
        current_date = Date.today
        COMPUTED_DATE_UNITS.each do |method, calculated_date_unit|
          if m = value.match(calculated_date_unit) && current_date.respond_to?(method)
            @calculated_date_units  = calculated_date_unit
            @calculated_date_number = value.gsub(calculated_date_unit, '').to_i
            @search_value           = current_date.send(method, @calculated_date_number)
          end
        end
      elsif question.long_text? || question.short_text?
        # TODO: find better solution if available for case insensitive search for free text input question
        @search_value = value.downcase
      end
    end
  end

  def result
    return [] if question.blank? || operator.blank? || value.blank?
    Participant.joins(response_sets: :responses).where(responses: {question_id: question.id}, stage: 'approved').where("#{search_subject} #{operator} ?", search_value)
  end

  def get_search
    search_condition_group.get_search
  end

  def display_value
    if question.multiple_choice? and !value.blank?
      question.answers.find(value.to_i).text
    elsif @is_calculated_date
      "#{value} (#{search_value})"
    else
      value
    end
  end
end
