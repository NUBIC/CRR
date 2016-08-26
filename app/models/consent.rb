class Consent < ActiveRecord::Base
  # Globals
  TYPES         = ['Adult','Child'].freeze
  RELATIONSHIPS = ['Parent', 'Legal Guardian', 'Authorized Agent', 'Spouse'].freeze

  # Dependencies
  include WithActiveState

  # Associations
  has_many :consent_signatures, dependent: :restrict_with_error

  # Validations
  validates :state, inclusion: { in: STATES }, presence: true, uniqueness: { scope: :consent_type, if: :active?, message: 'Only one active consent per category allowed' }

  # Hooks
  after_initialize :default_args

  # Scopes
  default_scope { order('state ASC, created_at DESC') }

  def self.has_active_consent?
    child_consent.present? && adult_consent.present?
  end

  def self.child_consent
    Consent.active.where(consent_type: 'Child').order('created_at DESC').first
  end

  def self.adult_consent
    Consent.active.where(consent_type: 'Adult').order('created_at DESC').first
  end

  def editable?
    !active? && consent_signatures.empty?
  end

  private
    def default_args
      self.deactivate if self.state.blank?
    end
end
