class Survey < ActiveRecord::Base
  # Dependencies
  include WithActiveState

  # Associations
  has_many :response_sets, dependent: :restrict_with_exception
  has_many :sections, dependent: :destroy

  # Validations
  validates_presence_of :title
  validates :state, inclusion: { in: STATES }, presence: true
  validates_uniqueness_of :code, allow_blank: true, if: :active?
  validate :activation_check

  # Hooks
  after_create :create_section, unless: :multiple_section?
  after_initialize :default_args

  # Scopes
  default_scope {order('state ASC, created_at DESC')}

  def questions
    Question.where(section_id: sections.collect{|s| s.id})
  end

  def self.adult_survey
    Survey.active.where(code: 'adult').order('created_at DESC').first
  end

  def self.child_survey
    Survey.active.where(code: 'child').order('created_at DESC').first
  end

  def self.has_active_survey?
    child_survey && adult_survey
  end

  def deletable?
    !active? && response_sets.empty?
  end

  #this method checks that the survey is in fact valid for activation
  #checks things like it has at least one section, at least one question etc
  def soft_errors
    activation_errors = []
    if sections.size < 1
      activation_errors << "must have at least one section"
    else
      sections.each do |section|
        activation_errors << section.soft_errors
      end
    end
    return activation_errors.flatten.uniq.compact
  end

  private
    def activation_check
      if active?
        errors.add(:survey,soft_errors.to_sentence) unless soft_errors.empty?
      end
    end

    def create_section
      sections.create(title: 'questions')
    end

    def default_args
      self.deactivate if self.state.blank?
    end
end

