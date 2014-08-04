# == Schema Information
#
# Table name: study_involvements
#
#  id             :integer          not null, primary key
#  study_id       :integer
#  participant_id :integer
#  start_date     :date
#  end_date       :date
#  warning_date   :date
#  state          :string(255)
#  state_date     :date
#  notes          :text
#  created_at     :datetime
#  updated_at     :datetime
#

class StudyInvolvement < ActiveRecord::Base
  belongs_to :study
  belongs_to :participant

  VALID_STATES=['none','enrolled','declined','no contact','withdrew','excluded','completed']

  validates_presence_of :start_date, :participant, :study, :end_date
  validates_uniqueness_of :participant_id, :scope => :study
  validate :end_date_cannot_be_before_start_date
  validates_inclusion_of :state, :in => VALID_STATES

  scope :active, -> { where("start_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')") }
  scope :warning, -> { where("warning_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')") }

  after_initialize :default_args

  def active?
    (self.end_date.blank? or self.start_date <= Date.today) and (self.end_date.blank? or self.end_date > Date.today)
  end

  private
  def end_date_cannot_be_before_start_date
    if end_date.present? && end_date < start_date
      errors.add(:end_date, "can't be before start_date")
    end
  end
  def default_args
    self.state= 'none' if self.state.blank?
  end
end
