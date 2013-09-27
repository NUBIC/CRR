class Study < ActiveRecord::Base
  has_many :study_involvements

  def state
  end
end
