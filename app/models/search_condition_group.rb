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
  validates_presence_of :search_condition_group, :if=>"search.nil?"
  validates_inclusion_of :operator, :in => ["&","|"],:allow_blank=>false
  VALID_OPERATORS=["|","&"].freeze
  OPERATOR_TRANSLATIONS={"|"=>"OR","&"=>"AND"}.freeze

  def result
    return [] if search_conditions.empty? and search_condition_groups.empty?
    sc_result = search_conditions.collect{|sc| sc.result}.inject(operator.to_sym)
    return sc_result if search_condition_groups.empty?
    scg_result = search_condition_groups.collect{|scg| scg.result}.inject(operator.to_sym) 
    return scg_result if search_conditions.empty? 
    [sc_result,scg_result].inject(operator.to_sym)
  end

  def search
    super.nil? ? self.search_condition_group.search : super
  end

  def invert_operator
    return "&" if operator.eql?("|")
    return "|" if operator.eql?("&")
  end

  def pretty_operator
    OPERATOR_TRANSLATIONS[operator]
  end

end
