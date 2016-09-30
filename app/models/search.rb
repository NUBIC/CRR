class Search < ActiveRecord::Base
  # Dependencies
  include AASM

  # Associations
  belongs_to  :study
  belongs_to  :user
  has_one     :search_condition_group, dependent: :destroy
  has_many    :search_participants,    dependent: :destroy
  has_many    :study_involvements, through: :search_participants
  has_many    :comments, as: :commentable, dependent: :destroy

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
    state :data_requested, :data_released, :data_returned, :data_return_approved

    event :request_data do
      transitions from: :new, to: :data_requested, after: [:process_request]
    end

    event :release_data do
      transitions from: [:data_requested, :new], to: :data_released, after: :process_release
    end

    event :complete_data_return do
      transitions from: :data_released, to: :data_returned, guard: :all_participants_returned?, after: :set_return_completed_date
    end

    event :approve_data_return do
      transitions from: :data_returned, to: :data_return_approved, after: :set_return_approved_date
    end
  end

  # Scopes
  def self.requested
    where(state: 'data_requested')
  end

  def self.released
    where(state: 'data_released')
  end

  def self.returned
    where(state: 'data_returned')
  end

  def self.return_approved
    where(state: 'data_return_approved')
  end

  def self.expiring
    where("#{self.table_name}.warning_date <= '#{Date.today}' and (#{self.table_name}.end_date is null or #{self.table_name}.end_date >= '#{Date.today}')")
  end

  def self.all_released
    where(state: ['data_released', 'data_returned', 'data_return_approved'])
  end

  def self.default_ordering
    joins(:study).order('created_at DESC, studies.name ASC').readonly(false)
  end

  def self.with_user(user)
    includes(study: [:user_studies, :searches]).where( user_studies: { user_id: user.id })
  end

  # Functions
  def result(options={})
    return [] if search_condition_group.nil? || search_condition_group.result.nil?
    results = search_condition_group.result.reject {|p| p.do_not_contact? }
    if options[:extended_release]
      return results
    else
      return results.reject {|p| p.has_study?(study) }
    end
  end

  # Methods associated with state change

  # Triggered after researcher submits data request and state is changed to 'data requested'
  def process_request
    self.set_search_participants
    self.request_date = Date.today
    self.save
  end

  # Triggered after state is changed to 'release processed'.
  # Marks selected search participants as released and creates linked records in study_involvements table.
  # Populates release start, stop and warning dates for the search.
  def process_release(params)
    self.process_date = Date.today
    self.start_date   ||= params[:start_date]
    self.warning_date ||= params[:warning_date]
    self.end_date     ||= params[:end_date]
    self.save!

    self.set_search_participants(extended_release: params[:extended_release]) unless self.data_requested?
    self.search_participants.where(participant_id: params[:participant_ids]).each do |search_participant|
      search_participant.released           = true
      search_participant.study_involvement  = search_participant.participant.study_involvements.create(
        start_date: self.start_date,
        end_date: self.end_date,
        warning_date: self.warning_date,
        study_id: study.id,
        extended_release: params[:extended_release]
      )
      search_participant.save
    end
  end

  # Called on data return event. Updates status for selected study involvements.
  # Moves search to 'data_returned' state when all participants are returned.
  def process_return(params)
    study_involvements =  self.study_involvements.where(id: params[:study_involvement_ids])
    study_involvements.map{|i| i.update_attributes(status: params[:study_involvement_status])}
    self.complete_data_return! if self.all_participants_returned? && !self.data_returned?
  end

  # Called on return approval. Updates all study involvement statuses to 'approved' state
  # and changes search status to 'data_return_approved'
  def process_return_approval
    study_involvements =  self.study_involvements.map{|i| i.study_involvement_status.approve!}
    self.approve_data_return!
  end

  # Called on return request extension. Copies search conditions from source search and
  # releases participants from the provided list.
  def process_release_extention(params)
    source_search   = params[:source_search]
    participant_ids = params[:participant_ids]

    self.errors.add(:base, 'source search has to be provided')    if source_search.blank?
    self.errors.add(:base, 'participant ids have to be provided') if participant_ids.blank?

    unless self.errors.any?
      self.copy(source_search)
      self.release_data(participant_ids: participant_ids, extended_release: true)
    end
  end

  # Helper methods
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

  def all_participants_returned?
    study_involvements.count == study_involvements.joins(:study_involvement_status).count
  end

  def results_available?
    self.data_released? || self.data_returned? || self.data_return_approved?
  end

  def set_search_participants(params={})
    self.result(params).each {|participant| self.search_participants.create(participant: participant)}
  end

  private
    def default_args
      if self.id
        self.name = "Request_#{self.id}" if self.name.blank?
      else
        self.name = "Request_#{Search.all.size+1}" if self.name.blank?
      end
    end

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

    def set_return_approved_date
      self.return_approved_date = Date.today
      save
    end

    def set_return_completed_date
      self.return_completed_date = Date.today
      save
    end


end
