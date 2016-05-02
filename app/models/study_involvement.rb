class StudyInvolvement < ActiveRecord::Base
  # Dependencies
  has_paper_trail

  # Associations
  belongs_to :study
  belongs_to :participant
  has_one :study_involvement_state, dependent: :destroy

  accepts_nested_attributes_for :study_involvement_state, allow_destroy: true

  # Validations
  validates_presence_of :start_date, :participant, :study, :end_date
  validates_uniqueness_of :participant_id, scope: :study
  validate :end_date_cannot_be_before_start_date

  # Scopes
  scope :active,  -> { where("start_date <= '#{Date.today}' and end_date >= '#{Date.today}'") }
  scope :warning, -> { where("warning_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')") }

  def active?
    self.end_date >= Date.today
  end

  def state
    study_involvement_state ? study_involvement_state.name.titleize : ''
  end

  private
    def end_date_cannot_be_before_start_date
      if end_date.present? && end_date < start_date
        errors.add(:end_date, 'can\'t be before start_date')
      end
    end
end
