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

  belongs_to :search_condition_group
  belongs_to :question


  VALID_OPERATORS=["=","!=",">","<"].freeze
  VALID_ANSWER_OPERATORS=["=","!="].freeze
  OPERATOR_TRANSLATIONS={"="=>"equal to","!="=>"not equal to",">"=>"greater than","<"=>"less than"}.freeze

  validates_inclusion_of :operator, :in => ["=","!=",">","<","<=","=>"],:allow_blank=>true


  def result
    return [] if question.blank? || operator.blank? || value.blank?
    Participant.joins(:response_sets=>:responses).where("question_id = ? and #{subject} #{operator} ? and stage='approved'",question.id,value)
  end


  def subject
    return 'answer_id' if question.multiple_choice?
    return 'text::decimal' if question.number?
    return 'text::date' if question.date?
    return 'text' if question.long_text? or question.short_text?
  end

  def search
    search_condition_group.search
  end

  def display_value
    (question.multiple_choice? and !value.blank?) ? question.answers.find(value.to_i).text : value
  end

end
