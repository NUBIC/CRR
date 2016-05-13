class Search < ActiveRecord::Base
  # Dependencies
  include AASM

  # Associations
  belongs_to :study
  belongs_to :user
  has_one     :search_condition_group, dependent: :destroy
  has_many    :search_participants,    dependent: :destroy
  has_many    :study_involvements, through: :search_participants

  accepts_nested_attributes_for :search_condition_group, allow_destroy: true
  accepts_nested_attributes_for :search_participants
  accepts_nested_attributes_for :study_involvements

  # Validations
  validates_presence_of :study
  validates_presence_of :search_condition_group
  validate :end_date_cannot_be_before_start_date

  # Hooks
  before_validation :create_condition_group
  after_initialize :default_args

  # AASM events and transitions
  aasm column: :state do
    state :new, initial: true
    state :data_requested, :data_released

    event :request_data do
      transitions from: :new, to: :data_requested, after: [:process_request]
    end

    event :release_data do
      transitions from: [:data_requested, :new], to: :data_released, after: [:process_release]
    end
  end

  # Scopes
  def self.requested
    where(state: 'data_requested')
  end

  def self.released
    where(state: 'data_released')
  end

  def self.expiring
    where("#{self.table_name}.warning_date <= '#{Date.today}' and (#{self.table_name}.end_date is null or #{self.table_name}.end_date > '#{Date.today}')")
  end

  def self.default_ordering
    joins(:study).order('created_at DESC, studies.name ASC').readonly(false)
  end

  def self.with_user(user)
    includes(study: [:user_studies, :searches]).where( user_studies: { user_id: user.id })
  end

  # Functions
  def result
    return [] if search_condition_group.nil? || search_condition_group.result.nil?
    return search_condition_group.result.reject {|p| p.has_study?(study) | p.do_not_contact? }
  end

  def process_request
    result.each {|participant| self.search_participants.create(participant: participant)}
    self.request_date = Date.today
    self.save
  end

  def process_release(params)
    if self.data_requested?
      result_search_participants = self.search_participants.where(participant_id: params[:participant_ids])
      result_search_participants.each do |search_participant|
        search_participant.released = true
        study_involvement = search_participant.participant.study_involvements.create(start_date: params[:start_date], end_date: params[:end_date], warning_date: params[:warning_date], study_id: study.id)
        search_participant.study_involvement = study_involvement
        search_participant.save
      end
    else
      participants = Participant.find(params[:participant_ids])
      participants.each do |participant|
        search_participant  = self.search_participants.create(participant: participant, released: true)
        study_involvement   = participant.study_involvements.create(start_date: params[:start_date],end_date: params[:end_date],warning_date: params[:warning_date], study_id: study.id)
        search_participant.study_involvement = study_involvement
        search_participant.save
      end
      (self.result - participants).each{ |participant| self.search_participants.create(participant: participant)}
    end
    self.process_date = Date.today
    self.start_date   = params[:start_date]
    self.warning_date = params[:warning_date]
    self.end_date     = params[:end_date]
    self.save
  end

  def process_return(params)
    study_involvements =  self.study_involvements.where(id: params[:study_involvement_ids])
    study_involvements.map{|i| i.update_attributes(status: params[:study_involvement_status])}
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
    user.nil? ? '' : user.full_name
  end

  def display_name
    name.nil? ? '' : name
  end

  def copy(source_record)
    return unless source_record.is_a?(self.class)
    self.build_search_condition_group
    self.search_condition_group.copy(source_record.search_condition_group)
  end

  def user_emails
    self.study.user_emails.push(self.user.email).reject(&:blank?).uniq
  end

  def return_status
    if study_involvements.blank?
      nil
    elsif study_involvements.approved.size == study_involvements.size
      'return accepted'
    elsif study_involvements.pending.size == study_involvements.size
      'returned'
    elsif study_involvements.pending.any?
      'partially returned'
    end
  end

  private
    def end_date_cannot_be_before_start_date
      if end_date.present? && end_date <= start_date
        errors.add(:end_date, 'can\'t be before release date')
      end
    end

    def questions
      Question.find(parameters.keys.flatten.collect{|v| v.to_i})
    end

    def answers
      Answer.find(parameters.values.flatten.collect{|q| q[:answer_ids]}.flatten.compact.uniq.collect{|v| v.to_i})
    end

    def create_condition_group
      self.build_search_condition_group unless self.search_condition_group
    end
end
