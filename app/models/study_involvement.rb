# == Schema Information
#
# Table name: study_involvements
#
#  id             :integer          not null, primary key
#  study_id       :integer
#  participant_id :integer
#  start_date     :date
#  end_date       :date
#  notes          :text
#  created_at     :datetime
#  updated_at     :datetime
#

class StudyInvolvement < ActiveRecord::Base
  belongs_to :study
  belongs_to :participant

  validates_presence_of :start_date, :participant, :study
end
