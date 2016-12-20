class StudyInvolvement < ActiveRecord::Base
  # Dependencies
  has_paper_trail

  # Associations
  belongs_to :study
  belongs_to :participant
  has_one :study_involvement_status, dependent: :destroy
  has_one :search_participant_study_involvement
  has_one :search_participant, through: :search_participant_study_involvement, dependent: :destroy
  has_many :downloads, dependent: :restrict_with_error

  accepts_nested_attributes_for :study_involvement_status, allow_destroy: true, reject_if: proc { |attributes| attributes.all?{ |k,v| ['state', '_destroy'].include?(k) || v.blank? } }

  # Validations
  validates_presence_of :start_date, :participant, :study, :end_date
  validates_uniqueness_of :participant_id, scope: :study, conditions: -> { where(extended_release: [false, nil]) }, if: :original_release?, message: 'had already been released to the study. If extension is needed please indicate by checking the flag below.'
  validate :end_date_cannot_be_before_start_date

  # Scopes
  scope :active,    -> { where("start_date <= '#{Date.today}' and end_date >= '#{Date.today}'") }
  scope :warning,   -> { where("warning_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')") }
  scope :approved,  -> { joins(:study_involvement_status).where( study_involvement_statuses: { state: 'approved' })}
  scope :pending,   -> { joins(:study_involvement_status).where( study_involvement_statuses: { state: 'pending'})}
  default_scope { includes(:study_involvement_status) }

  def active?
    self.end_date >= Date.today
  end

  def inactive?
    end_date.present? && end_date < Date.today
  end

  def original_release?
    self.extended_release.blank?
  end

  def extended_release?
    self.extended_release
  end

  def status
    if study_involvement_status.present?
      if study_involvement_status.approved?
        study_involvement_status.name.titleize
      else
        study_involvement_status.state.titleize
      end
    else
      'None'
    end
  end

  def status=(status)
    if study_involvement_status.present?
      self.study_involvement_status.name = status
    else
      self.build_study_involvement_status(name: status)
    end
  end

  private
    def end_date_cannot_be_before_start_date
      if end_date.present? && end_date < start_date
        errors.add(:end_date, 'can\'t be before start_date')
      end
    end
end
