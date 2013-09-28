class Study < ActiveRecord::Base
  has_many :study_involvements

  scope :active, where("active_on < '#{Date.today}' and (inactive_on is null or inactive_on > '#{Date.today}')")

  def state
  end
end
