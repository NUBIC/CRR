# == Schema Information
#
# Table name: searches
#
#  id           :integer          not null, primary key
#  parameters   :text
#  connector    :string(255)
#  study_id     :integer
#  state        :string(255)
#  request_date :date
#  process_date :date
#  decline_date :date
#

class Search < ActiveRecord::Base

  include AASM

  belongs_to :study
  serialize :parameters, Hash

  aasm_column :state
  aasm_state :new, :initial => true
  aasm_state :data_requested
  aasm_state :data_released

  CONNECTORS = [ OR = 'or',
                 AND = 'and']

  validates_presence_of :connector, :parameters, :study
  validates_inclusion_of :connector, :in => CONNECTORS

  aasm_event :request_data do 
    transitions :to => :data_requested,:from=>[:new],:on_transition=> Proc.new {|obj, *args| obj.set_request_date }
  end

  aasm_event :release_data do 
    transitions :to => :data_released, :from=>[:data_requested],:on_transition=>[:process_release]
  end

  def result
    enrolled = connector.eql?(AND) ?  Participant.all : []
    search_responses = Response.arel_table
    results = []
    Rails.logger.info parameters.values.inspect
    answer_ids = parameters.values.flatten.collect{|q| q[:answer_ids]}.flatten.compact.uniq
    parameters.each do |k,parameter|
      question = questions.detect{|q| q.id.eql?(k.to_i)}   
      if question.multiple_choice?
        enrolled = enrolled & Participant.joins(:response_sets=>:responses).where("answer_id in (?)",parameter[:answer_ids]) if connector == AND
        enrolled = enrolled | Participant.joins(:response_sets=>:responses).where("answer_id in (?)",parameter[:answer_ids]) if connector == OR
      elsif question.number? and !parameter[:min].blank?  and !parameter[:max].blank?
        enrolled =enrolled & Participant.joins(:response_sets=>:responses).where("question_id = #{question.id} and text::decimal > ? and text::decimal < ?",parameter[:min],parameter[:max]) if connector == AND
        enrolled =enrolled | Participant.joins(:response_sets=>:responses).where("question_id = #{question.id} and text::decimal > ? and text::decimal < ?",parameter[:min],parameter[:max]) if connector == OR
      elsif question.date?
        enrolled =enrolled & Participant.joins(:response_sets=>:responses).where("question_id = #{question.id} and text::date > ? and text::date < ?",parameter[:min],parameter[:max]) if connector == AND
        enrolled =enrolled | Participant.joins(:response_sets=>:responses).where("question_id = #{question.id} and text::date > ? and text::date < ?",parameter[:min],parameter[:max]) if connector == OR
      end
    end
    enrolled
  end

  def full_parameters
    result = {}
    questions.each do |question|
     if ['pick_one','pick_many'].include?(question.response_type)    
       result[question]= question.answers.select{|a| answers.include?(a)}.collect{|answer| answer.text}
     elsif ['date'].include?(question.response_type)
       result[question]= "#{parameters[question.id.to_s.to_sym][:min]} to #{parameters[question.id.to_s.to_sym][:max]}"
     elsif ['number'].include?(question.response_type)
       result[question]= "#{parameters[question.id.to_s.to_sym][:min]} to #{parameters[question.id.to_s.to_sym][:max]}"
     end
    end
    return result
  end

  def pretty_parameters
    full_parameters
  end
  def process_release
    result.each do |participant|
      participant.study_involvements.create(:start_date=>Date.today,:study_id=>study.id) unless participant.do_not_contact
    end
  end
  def set_request_date
    self.request_date=Date.today
    save
  end
  private

    def questions
      Question.find(parameters.keys.flatten.collect{|v| v.to_i})
    end

    def answers
      Answer.find(parameters.values.flatten.collect{|q| q[:answer_ids]}.flatten.compact.uniq.collect{|v| v.to_i})
    end

end
