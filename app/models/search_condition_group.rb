class SearchConditionGroup < ActiveRecord::Base
  # Globals
  DEFAULT_GROUP_OPERATOR = '|'.freeze


  # Dependencies
  include SearchOperator

  # Associations
  belongs_to  :search_condition_group
  belongs_to  :search
  has_many    :search_conditions
  has_many    :search_condition_groups

  accepts_nested_attributes_for :search_conditions, allow_destroy: true
  accepts_nested_attributes_for :search_condition_groups, allow_destroy: true

  # Validations
  validates_inclusion_of :operator, in: group_operators.map{|o| o[:symbol]}
  validate :presence_of_search_or_search_condition_group

  # Hooks
  before_validation :validate_presence_of_operator

  def presence_of_search_or_search_condition_group
    return false if self.search.blank? && self.search_condition_group.blank?
  end

  def result
    return [] if search_conditions.empty? and search_condition_groups.empty?
    sc_result = search_conditions.collect{|sc| sc.result}.inject(operator.to_sym)
    return sc_result if search_condition_groups.empty?
    scg_result = search_condition_groups.collect{|scg| scg.result}.inject(operator.to_sym)
    return scg_result if search_conditions.empty?
    [sc_result, scg_result].inject(operator.to_sym)
  end

  def get_search
    self.search.nil? ? self.search_condition_group.get_search : self.search
  end

  def invert_operator
    return '&' if operator.eql?('|')
    return '|' if operator.eql?('&')
  end

  def is_or?
    operator.eql?('|')
  end

  def is_and?
    operator.eql?('&')
  end

  def has_conditions?
    search_conditions.any? || search_condition_groups.any?{ |search_condition_group| search_condition_group.has_conditions? }
  end

  def validate_presence_of_operator
    self.operator = DEFAULT_GROUP_OPERATOR if self.operator.blank?
  end

  def pretty_operator
    pretty_operator_by_type(GROUP_OPERATOR_TYPE)
  end

  def copy(source_record)
    raise TypeError, "source has to be an object of class #{self.class.to_s}" unless source_record.is_a?(self.class)
    self.operator = source_record.operator
    source_record.search_conditions.each do |source_search_condition|
      search_condition = self.search_conditions.build
      search_condition.copy(source_search_condition)
    end

    source_record.search_condition_groups.each do |source_search_condition_group|
      search_condition_group = self.search_condition_groups.build
      search_condition_group.copy(source_search_condition_group)
    end
  end
end
