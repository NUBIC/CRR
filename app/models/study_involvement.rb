class StudyInvolvement < ActiveRecord::Base
  belongs_to :study
  belongs_to :participant

  validates_presence_of :start_date,:participant,:study
end
