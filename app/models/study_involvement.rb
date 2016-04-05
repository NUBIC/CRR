class StudyInvolvement < ActiveRecord::Base
  # Globals
  VALID_STATES = ['none', 'enrolled', 'declined', 'no contact', 'withdrew', 'excluded', 'completed'].freeze

  # Associations
  belongs_to :study
  belongs_to :participant

  # Validations
  validates_presence_of :start_date, :participant, :study, :end_date
  validates_uniqueness_of :participant_id, scope: :study
  validate :end_date_cannot_be_before_start_date
  validates_inclusion_of :state, in: VALID_STATES

  # Hooks
  after_initialize :default_args

  # Scopes
  scope :active,  -> { where("start_date <= '#{Date.today}' and end_date >= '#{Date.today}'") }
  scope :warning, -> { where("warning_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')") }

  def active?
    self.end_date >= Date.today
  end

  private
    def end_date_cannot_be_before_start_date
      if end_date.present? && end_date < start_date
        errors.add(:end_date, 'can\'t be before start_date')
      end
    end

    def default_args
      self.state = 'none' if self.state.blank?
    end
end
