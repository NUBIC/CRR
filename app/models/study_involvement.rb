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
#  notes          :text
#  created_at     :datetime
#  updated_at     :datetime
#

class StudyInvolvement < ActiveRecord::Base
  belongs_to :study
  belongs_to :participant

  validates_presence_of :start_date, :participant, :study
  validate :end_date_cannot_be_before_start_date

  scope :active, -> { where("start_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')") }
  scope :warning, -> { where("warning_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')") }



  private
  def end_date_cannot_be_before_start_date
    if end_date.present? && end_date < start_date
      errors.add(:end_date, "can't be before start_date")
    end
  end
end
