class Participant < ActiveRecord::Base
  # Dependencies
  include AASM

  # Associations
  has_many :response_sets, dependent: :destroy
  has_many :surveys, through: :response_sets
  has_many :contact_logs, dependent: :destroy
  has_many :study_involvements, -> { order('end_date DESC') }, dependent: :destroy
  has_many :origin_relationships, class_name: 'Relationship', foreign_key: 'origin_id', dependent: :destroy
  has_many :destination_relationships, class_name: 'Relationship', foreign_key: 'destination_id', dependent: :destroy
  has_many :consent_signatures, dependent: :destroy
  has_many :studies, through: :study_involvements
  has_many :search_participants, dependent: :destroy
  has_one :account_participant, dependent: :destroy
  has_one :account, through: :account_participant

  accepts_nested_attributes_for :origin_relationships, allow_destroy: true

  # Validations
  validates :email, format: {with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i }, allow_blank: true
  validates :primary_phone, :secondary_phone, format: {with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/}, allow_blank: true
  validates :zip, numericality: true, allow_blank: true, length: { maximum: 5 }

  # AASM events and transitions
  aasm_column :stage
  aasm_state :consent, initial: true
  aasm_state :consent_denied
  aasm_state :demographics
  aasm_state :survey
  aasm_state :pending_approval
  aasm_state :approved
  aasm_state :withdrawn

  # Scopes
  scope :by_stage,              -> (stages){ where(stage: stages) }
  scope :pending_approvals,     -> { by_stage('pending_approval').order("#{self.table_name}.created_at DESC") }
  scope :approved,              -> { by_stage('approved').order("#{self.table_name}.created_at DESC") }
  scope :approaching_deadlines, -> { joins(:study_involvements).by_stage('approved').where("study_involvements.start_date IS NOT NULL and ((study_involvements.warning_date <= '#{Date.today}' or study_involvements.warning_date IS NULL) and (end_date is null or end_date > '#{Date.today}'))")}
  scope :all_participants,      -> { by_stage(['approved', 'pending_approval']).order("#{self.table_name}.created_at DESC") }
  scope :search,                -> (param){ where('first_name ilike ? or last_name ilike ?',"%#{param}%","%#{param}%") }

  aasm_event :sign_consent do
    transitions to: :demographics, from: :consent, on_transition: :create_consent_signature
  end

  aasm_event :take_survey do
    transitions to: :survey, from: :demographics
    # , guard: :demographics_info_completed?
  end

  aasm_event :decline_consent do
   transitions to: :consent_denied, from: :consent
  end

  aasm_event :process_approvement do
    transitions to: :approved, from: :survey, guard: Proc.new {|p| !p.proxy? }
    transitions to: :pending_approval, from: :survey, guard: :proxy?
  end

  aasm_event :verify do
    transitions to: :approved, from: :pending_approval
  end

  aasm_event :approve do
    transitions to: :approved, from: :pending_approval
    transitions to: :approved, from: :survey
  end

  aasm_event :withdraw do
    transitions to: :withdrawn
  end

  def self.all_active_participants
    approaching_deadlines = Participant.approaching_deadlines
    Participant.pending_approvals | approaching_deadlines | Participant.approved.where.not(id: approaching_deadlines.map(&:id)).order('created_at DESC')
  end

  def filled_states
    [:consent, :demographics, :survey]
  end

  # condensed form of name
  def name
    [first_name, last_name].join(' ')
  end

  def relationships
    origin_relationships + destination_relationships
  end

  def has_relationships?
    relationships.size > 0
  end

  def has_followup_survey?
    surveys.reject{|s| s.code == "adult" or s.code == "child"}.size > 0
  end

  # condensed form of address
  def address
    addr = [address_line1, address_line2, city].reject(&:blank?).join(' ').strip
    addr1 = [state, zip].reject(&:blank?).join(' ').strip
    addr1.blank? ? addr.blank? ? nil : addr : addr << "," << addr1
  end

  def on_study?
    study_involvements.active.count > 0
  end

  def has_study?(study)
    !studies.empty? && studies.include?(study)
  end

  def search_display
    [name, address, email, primary_phone].reject{|r| r.blank?}.join(' - ').strip
  end

  def create_consent_signature(params)
    consent_signatures.create(params)
  end

  def create_response_set(survey)
    response_sets.create(survey_id: survey.id)
  end

  def most_recent_consent_signature
    consent_signatures.first
  end

  def adult_proxy?
    !child && account_participant.proxy
  end

  def child_proxy?
    child && account_participant.proxy
  end

  def proxy?
    account_participant.nil? ? false : account_participant.proxy
  end

  def open?
    [:consent, :demographics, :survey].include?(self.aasm_current_state)
  end

  def consented?
    [:demographics, :completed, :survey, :pending_approval, :approved].include?(self.aasm_current_state) and !self.consent_signatures.empty?
  end

  def completed?
    [:pending_approval, :approved].include?(self.aasm_current_state)
  end

  def inactive?
    [:new, :consent, :demographics, :consent_denied].include?(self.aasm_current_state)
  end

  def active?
    !inactive?
  end

  def active_studies
    study_involvements.active.collect{|si| si.study if si.study.active? }.flatten.uniq
  end

  def recent_response_set
    response_sets.order("updated_at DESC").first
  end

  def open_public_response_sets
    response_sets.where(completed_at: nil,public: true)
  end

  def public_response_sets
    response_sets
  end

  def demographics_info_completed?
    !(first_name.blank? or last_name.blank?)
  end

  def related_participants
    account.other_participants(self)
  end

  def copy_from(participant)
    [ :address_line1, :address_line2, :city, :state, :zip, :email, :primary_phone, :secondary_phone ].each do |fillin_attr|
      self.send("#{fillin_attr}=", participant.send(fillin_attr))
    end

    if !account.nil? and proxy?
      [ :primary_guardian_first_name, :primary_guardian_last_name, :primary_guardian_email, :primary_guardian_phone,
        :secondary_guardian_first_name, :secondary_guardian_last_name, :secondary_guardian_email, :secondary_guardian_phone, :hear_about_registry].each do |fillin_attr|
        self.send("#{fillin_attr}=", participant.send(fillin_attr))
      end
    end
  end

  def contact_emails
    contact_emails = Hash.new
    contact_emails["Self - #{email}"] = email unless email.blank?
    contact_emails["Primary Guardian - #{primary_guardian_email}"] = primary_guardian_email unless primary_guardian_email.blank?
    contact_emails["Secondary Guardian - #{secondary_guardian_email}"] = secondary_guardian_email unless secondary_guardian_email.blank?
    contact_emails["Account Email - #{self.account.email}"] = self.account.email if self.account
    contact_emails
  end

  def released?(search)
    search_participants.where(search_id: search.id, released: true).any?
  end
end
