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
#  start_date   :date
#  warning_date :date
#  end_date     :date
#  name         :string(255)
#  user_id      :integer
#

class Search < ActiveRecord::Base
  include AASM
  belongs_to :study
  belongs_to :user
  has_one :search_condition_group
  has_many :search_participants, :dependent => :destroy

  aasm_column :state
  aasm_state :new, :initial => true
  aasm_state :data_requested
  aasm_state :data_released

  validates_presence_of :study

  aasm_event :request_data do
    transitions :to => :data_requested,:from=>[:new], :on_transition=>[:process_request]
  end

  aasm_event :release_data do
    transitions :to => :data_released, :from=>[:data_requested,:new],:on_transition=>[:process_release]
  end

  after_create :create_condition_group
  after_initialize :default_args

  scope :requested, -> { where(state: :data_requested).joins(:study).order('request_date DESC, studies.name ASC').readonly(false)}
  scope :released, -> { where(state: :data_released).joins(:study).order('process_date DESC, studies.name ASC').readonly(false)}

  scope :default_ordering, -> {
    joins(:study).order('created_at DESC, studies.name ASC').readonly(false)
  }

  scope :with_user, lambda { |user|
    Search.joins(study: [:user_studies, :searches]).where('user_studies.user_id' => user.id).distinct
  }

  def result
    return [] if search_condition_group.nil? || search_condition_group.result.nil?
    return search_condition_group.result.reject {|p| p.has_study?(study) | p.do_not_contact? }
  end

  def released_participants
    search_participants.release.collect{|sp| sp.participant}.flatten.uniq
  end

  def process_request(params)
    result.each {|participant| self.search_participants.create(participant: participant)}
    self.request_date=Date.today
    save
  end

  def process_release(params)
    if self.data_requested?
      result_search_participants = self.search_participants.where(participant_id: params[:participant_ids].keys.collect{|k| k.to_i}.flatten.uniq.compact)
      result_search_participants.each do |sp|
        sp.released = true
        sp.participant.study_involvements.create(start_date: params[:start_date], end_date: params[:end_date], warning_date: params[:warning_date], study_id: study.id)
        sp.save
      end
    else
      participants = Participant.find(params[:participant_ids].keys.collect{|k| k.to_i}.flatten.uniq.compact)
      participants.each do |participant|
        self.search_participants.create(participant: participant, released: true)
        si = participant.study_involvements.create(:start_date=>params[:start_date],:end_date=>params[:end_date],:warning_date=>params[:warning_date],:study_id=>study.id)
      end
      (self.result - participants).each { |participant| self.search_participants.create(participant: participant)}
    end
    self.process_date = Date.today
    self.start_date = params[:start_date]
    self.warning_date = params[:warning_date]
    self.end_date = params[:end_date]
    self.save
  end

  def set_request_date
    self.request_date=Date.today
    save
  end

  def default_args
    if self.id
      self.name = "Request_#{self.id}" if self.name.blank?
    else
      self.name = "Request_#{Search.all.size+1}" if self.name.blank?
    end
  end

  def display_user
    user.nil? ? "" : user.try(:name)
  end

  def display_name
    name.nil? ? "" : name
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
