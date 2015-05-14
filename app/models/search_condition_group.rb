# == Schema Information
#
# Table name: search_condition_groups
#
#  id                        :integer          not null, primary key
#  search_id                 :integer
#  search_condition_group_id :integer
#  operator                  :string(255)
#

class SearchConditionGroup < ActiveRecord::Base
  include SearchOperator

  belongs_to  :search_condition_group
  belongs_to  :search
  has_many    :search_conditions
  has_many    :search_condition_groups

  validates_inclusion_of :operator, in: group_operators.map{|o| o[:symbol]}
  validate :presence_of_search_or_search_condition_groups

  before_validation :validate_presence_of_operator

  DEFAULT_GROUP_OPERATOR = '|'.freeze

  def presence_of_search_or_search_condition_groups
    return false if self.search.blank? && self.search_condition_groups.empty?
  end

  def result
    return [] if search_conditions.empty? and search_condition_groups.empty?
    sc_result = search_conditions.collect{|sc| sc.result}.inject(operator.to_sym)
    return sc_result if search_condition_groups.empty?
    scg_result = search_condition_groups.collect{|scg| scg.result}.inject(operator.to_sym)
    return scg_result if search_conditions.empty?
    [sc_result,scg_result].inject(operator.to_sym)
  end

  def get_search
    self.search.nil? ? self.search_condition_group.get_search : self.search
  end

  def invert_operator
    return "&" if operator.eql?("|")
    return "|" if operator.eql?("&")
  end

  def is_or?
    operator.eql?("|")
  end

  def is_and?
    operator.eql?("&")
  end

  def has_conditions?
    search_conditions.any? || search_condition_groups.joins(:search_conditions).all.any?
  end

  def validate_presence_of_operator
    self.operator = DEFAULT_GROUP_OPERATOR if self.operator.blank?
  end
end
