# == Schema Information
#
# Table name: participants
#
#  id                            :integer          not null, primary key
#  email                         :string(255)
#  first_name                    :string(255)
#  middle_name                   :string(255)
#  last_name                     :string(255)
#  primary_phone                 :string(255)
#  secondary_phone               :string(255)
#  address_line1                 :string(255)
#  address_line2                 :string(255)
#  city                          :string(255)
#  state                         :string(255)
#  zip                           :string(255)
#  stage                         :string(255)
#  do_not_contact                :boolean
#  child                         :boolean
#  notes                         :text
#  primary_guardian_first_name   :string(255)
#  primary_guardian_last_name    :string(255)
#  primary_guardian_email        :string(255)
#  primary_guardian_phone        :string(255)
#  secondary_guardian_first_name :string(255)
#  secondary_guardian_last_name  :string(255)
#  secondary_guardian_email      :string(255)
#  secondary_guardian_phone      :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#

class Participant < ActiveRecord::Base
  include AASM
  has_many :response_sets
  has_many :contact_logs
  has_many :study_involvements
  has_many :origin_relationships,:class_name=>"Relationship",:foreign_key=>"origin_id"
  has_many :destination_relationships,:class_name=>"Relationship",:foreign_key=>"destination_id"
  has_many :consent_signatures
  has_many :studies, :through=>:study_involvements

  has_one :account_participant
  has_one :account, :through => :account_participant
  accepts_nested_attributes_for :origin_relationships, :allow_destroy => true

  validates :email, :format => {:with =>/\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i }, allow_blank: true
  validates :primary_phone, :secondary_phone, :format => {:with =>/\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/}, allow_blank: true
  validates :zip, :numericality => true, allow_blank: true, :length => { :maximum => 5 }

  aasm_column :stage
  aasm_state :consent, :initial => true
  aasm_state :consent_denied
  aasm_state :demographics
  aasm_state :survey
  aasm_state :survey_started
  aasm_state :verification_needed
  aasm_state :enrolled
  aasm_state :withdrawn

  aasm_event :sign_consent do
    transitions :to => :demographics, :from => :consent, :on_transition => :create_consent_signature
  end

  aasm_event :take_survey do
    transitions :to => :survey, :from => :demographics
    # , :guard => :demographics_info_completed?
  end

  aasm_event :start_survey do
    transitions :to => :survey_started, :from => :survey
  end

  aasm_event :finish_survey do
    transitions :to => :completed, :from => :survey_started
  end

  aasm_event :decline_consent do
   transitions :to => :consent_denied, :from =>:consent
  end

  aasm_event :process_enrollment do
    transitions :to => :enrolled, :from => :survey_started, :guard => Proc.new {|p| !p.proxy? }
    transitions :to => :verification_needed, :from => :survey_started, :guard => :proxy?
  end

  aasm_event :verify do
    transitions :to => :enrolled, :from => :verification_needed
  end

  aasm_event :enroll do
    transitions :to => :enrolled, :from => :verification_needed
    transitions :to => :enrolled, :from => :survey_started
  end

  aasm_event :withdraw do
    transitions :to => :withdrawn
  end

  scope :search , proc {|param|
    where("first_name ilike ? or last_name ilike ? ","%#{param}%","%#{param}%")}

  # condensed form of name
  def name
    [first_name, last_name].join(' ')
  end

  def proxy_name
    if first_name.blank? and last_name.blank?
      proxy? ? child_proxy? ? "No Name Child Enrollment" : "No Name Adult Enrollment" : "Self Enrollment"
    else
      name
    end
  end

  def relationships
    origin_relationships + destination_relationships
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
    account_participant.proxy
  end

  def open?
    [:consent, :demographics, :surevey, :survey_started].include?(self.aasm_current_state)
  end

  def consented?
    [:demographics, :completed, :survey, :survey_started, :verification_needed, :enrolled].include?(self.aasm_current_state) and !self.consent_signatures.empty?
  end

  def completed?
    [:verification_needed, :enrolled].include?(self.aasm_current_state)
  end

  def inactive?
    [:new, :consent, :demographics].include?(self.aasm_current_state)
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
    response_sets.where(:completed_at=>nil,:public=>true)
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
        :secondary_guardian_first_name, :secondary_guardian_last_name, :secondary_guardian_email, :secondary_guardian_phone].each do |fillin_attr|
        self.send("#{fillin_attr}=", participant.send(fillin_attr))
      end
    end
  end

  def contact_emails
    contact_emails = Hash.new
    contact_emails["Self - #{email}"] = email unless email.blank?
    contact_emails["Primary Guardian - #{primary_guardian_email}"] = primary_guardian_email unless primary_guardian_email.blank?
    contact_emails["Secondary Guardian - #{secondary_guardian_email}"] = secondary_guardian_email unless secondary_guardian_email.blank?
    contact_emails
  end
end
