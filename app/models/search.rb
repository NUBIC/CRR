# == Schema Information
#
# Table name: searches
#
#  id           :integer          not null, primary key
#  study_id     :integer
#  state        :string(255)
#  request_date :date
#  process_date :date
#  decline_date :date
#

class Search < ActiveRecord::Base

  include AASM

  belongs_to :study
  has_one :search_condition_group

  aasm_column :state
  aasm_state :new, :initial => true
  aasm_state :data_requested
  aasm_state :data_released

  validates_presence_of :study


  aasm_event :request_data do 
    transitions :to => :data_requested,:from=>[:new],:on_transition=> Proc.new {|obj, *args| obj.set_request_date }
  end

  aasm_event :release_data do 
    transitions :to => :data_released, :from=>[:data_requested],:on_transition=>[:process_release]
  end

  after_create :create_condition_group

  def result
    return [] if search_condition_group.nil? || search_condition_group.result.nil?
    return search_condition_group.result
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

    def create_condition_group
      SearchConditionGroup.create(:search_id=>self.id,:operator=>"|")
    end

end
