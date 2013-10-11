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
    enrolled = Participant.all
    Rails.logger.info parameters.values.inspect
    answer_ids = parameters.values.flatten
    responses = Response.where("answer_id in (#{answer_ids.join(",")})") 
    return [] if responses.nil?
    if connector == OR
      @participants = responses.collect{|r| r.response_set.participant if enrolled.include?(r.response_set.participant)}
    elsif connector == AND
      answer_ids_to_include = parameters.keys.to_a
      @participants = responses.collect{|r| r.response_set.participant if (enrolled.include?(r.response_set.participant) && r.response_set.participant && response_set_includes_all_of(r.response_set, answer_ids_to_include))}
    end
    @participants.uniq.compact
  end

  def full_parameters
    result = {}
    questions.each do |question|
     result[question]= question.answers.select{|a| answers.include?(a)}
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
    def response_set_includes_all_of(response_set, answer_ids)
      answer_ids_in_responses = response_set.responses.collect{|r| r.answer_id.to_s}
      answer_ids.all?{|ai| answer_ids_in_responses.include?(ai) }
    end

    def questions
      Question.find(parameters.keys.flatten.collect{|v| v.to_i})
    end

    def answers
      Answer.find(parameters.values.flatten.collect{|v| v.to_i})
    end

end
