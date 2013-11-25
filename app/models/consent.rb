# == Schema Information
#
# Table name: consents
#
#  id           :integer          not null, primary key
#  content      :text
#  state        :string(255)
#  accept_text  :string(255)      default("I Accept")
#  decline_text :string(255)      default("I Decline")
#  consent_type :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Consent < ActiveRecord::Base
  has_many :consent_signatures,:dependent=>:restrict_with_error

  TYPES = ['Adult','Child']
  STATES= ['active','inactive']

  validates_inclusion_of :state, :in => STATES
  validates_uniqueness_of :state, :scope =>:consent_type, :if=>:active?,:message=>"Only one active consent per category allowed"
  after_initialize :default_args



  def self.has_active_consent?
    child_consent and adult_consent
  end

  def self.child_consent
    Consent.where("consent_type ='Child' AND state ='active'").order("created_at DESC").first
  end

  def self.adult_consent
    Consent.where("consent_type ='Adult' AND state ='active'").order("created_at DESC").first
  end

  def active?
    state.eql?('active')
  end

  def editable?
    !active? and consent_signatures.empty?
  end

  private
  def default_args
    self.state ||='inactive'
  end

  def check_consent_signatures
    if self.content_type_changed? or self.content_changed?
      errors.add(:consent,"has been signed by users and can't be edited") unless answers.empty?
    end
  end
end
