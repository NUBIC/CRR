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

  belongs_to :search_condition_group
  belongs_to :search
  has_many :search_conditions
  has_many :search_condition_groups

  validates_presence_of :search, :if=>"search_condition_group.nil?"
  validates_inclusion_of :operator, :in => ["&","|"],:allow_blank=>false
  VALID_OPERATORS=["|","&"].freeze
  OPERATOR_TRANSLATIONS={"|"=>"Any Condition","&"=>"All Conditions"}.freeze

  def result
    temp_result = search_conditions.collect{|sc| sc.result}
    temp_result << search_condition_groups.collect{|scg| scg.result} unless search_condition_groups.empty?
    temp_result.empty? ? [] : temp_result.inject(operator.to_sym).flatten
  end

  def search
    super.nil? ? self.search_condition_group.search : super
  end

  def invert_operator
    return "&" if operator.operator.eql?("|")
    return "|" if operator.operator.eql?("&")
  end

end
